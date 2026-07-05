import { Injectable, UnauthorizedException, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { MailerService } from '@nestjs-modules/mailer';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { UpdateProfileDto, LanguageUpdateDto, DeleteAccountDto } from './dto/profile.dto';
import { PasswordResetRequestDto, PasswordResetTokenDto, PasswordResetConfirmDto } from './dto/password.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private mailerService: MailerService,
  ) {}

  private async findUserByIdentifier(identifier: string) {
    return this.prisma.user.findFirst({
      where: {
        OR: [
          { username: identifier },
          { email: identifier },
          { phone: identifier },
        ],
      },
      include: { city: true },
    });
  }

  private serializeUser(user: any) {
    // Mimic the Django _serialize_profile format
    return {
      id: user.id,
      username: user.username,
      email: user.is_deleted ? null : user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      phone: user.phone,
      city: user.city ? {
        id: user.city.id,
        name: user.city.name, // Assuming city has name. Might need adjustments based on true Prisma model
      } : null,
      image: null, // As requested by user, always null or global avatar
      is_superuser: user.is_superuser,
      is_company_member: false, // We will calculate this later when companies are implemented
      security_question: user.security_question,
      security_answer: user.security_answer,
      company: null, 
      is_deleted: user.is_deleted,
      display_name: `${user.first_name} ${user.last_name}`.trim(),
    };
  }

  async login(data: LoginDto) {
    const user = await this.findUserByIdentifier(data.identifier);

    if (!user || user.is_deleted || !user.is_active) {
      throw new UnauthorizedException('This account has been deleted or is inactive.');
    }

    // Since we are migrating from Django, some passwords might be using PBKDF2.
    // If they were bcrypt, bcrypt.compare works. If they are Django hashes, we'd need a custom hasher.
    // For now, assuming new users use bcrypt. 
    // TODO: In a real migration, handle Django's pbkdf2_sha256 format.
    const isPasswordValid = await bcrypt.compare(data.password, user.password);
    
    // NOTE FOR DJANGO HASH: If using Django PBKDF2, we need a custom checker.
    // For this lesson, we will assume standard NestJS bcrypt flow.
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Update last_login
    await this.prisma.user.update({
      where: { id: user.id },
      data: { last_login: new Date() },
    });

    const token = this.jwtService.sign({ id: user.id, username: user.username });
    return { token, user: this.serializeUser(user), message: 'Login successful' };
  }

  async register(data: RegisterDto) {
    const usernameTaken = await this.prisma.user.findFirst({ where: { username: data.username } });
    if (usernameTaken || data.username === 'profile') {
      throw new BadRequestException({ message: 'Username taken', error: { username: 'This username is already taken' } });
    }

    const emailTaken = await this.prisma.user.findFirst({ where: { email: data.email } });
    if (emailTaken) {
      throw new BadRequestException({ message: 'Email already registered', error: { email: 'This email is already registered' } });
    }

    const phoneTaken = await this.prisma.user.findFirst({ where: { phone: data.phone } });
    if (phoneTaken) {
      throw new BadRequestException({ message: 'Phone already registered', error: { phone: 'This phone number is already registered' } });
    }

    const hashedPassword = await bcrypt.hash(data.password, 10);

    const user = await this.prisma.user.create({
      data: {
        username: data.username,
        email: data.email,
        phone: data.phone,
        password: hashedPassword,
        first_name: data.first_name,
        last_name: data.last_name,
        cityId: data.city_id,
      },
      include: { city: true },
    });

    const token = this.jwtService.sign({ id: user.id, username: user.username });
    return { token, user: this.serializeUser(user), message: 'Registration successful' };
  }

  async getProfile(userId: number) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { city: true },
    });
    
    if (!user || user.is_deleted) {
      throw new NotFoundException('Profile not available');
    }
    
    return { data: this.serializeUser(user), message: 'Profile fetched successfully' };
  }

  async updateProfile(userId: number, data: UpdateProfileDto) {
    const currentUser = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!currentUser) throw new NotFoundException('User not found');

    if (data.username) {
      const existing = await this.prisma.user.findFirst({ where: { username: data.username, id: { not: userId } } });
      if (existing) throw new BadRequestException({ message: 'Username taken', error: { username: 'This username is already taken' } });
    }

    if (data.email) {
      const existing = await this.prisma.user.findFirst({ where: { email: data.email, id: { not: userId } } });
      if (existing) throw new BadRequestException({ message: 'Email taken', error: { email: 'This email is already taken' } });
    }

    if (data.phone) {
      const existing = await this.prisma.user.findFirst({ where: { phone: data.phone, id: { not: userId } } });
      if (existing) throw new BadRequestException({ message: 'Phone taken', error: { phone: 'This phone number is already taken' } });
    }

    const updatedUser = await this.prisma.user.update({
      where: { id: userId },
      data: {
        ...(data.username && { username: data.username }),
        ...(data.email && { email: data.email }),
        ...(data.phone && { phone: data.phone }),
        ...(data.first_name && { first_name: data.first_name }),
        ...(data.last_name && { last_name: data.last_name }),
        ...(data.city_id && { cityId: data.city_id }),
        ...(data.security_question && { security_question: data.security_question }),
        ...(data.security_answer && { security_answer: data.security_answer }),
      },
      include: { city: true },
    });

    return { data: this.serializeUser(updatedUser), message: 'Profile updated successfully' };
  }

  async getUsers(page: number = 1, limit: number = 12) {
    const skip = (page - 1) * limit;
    const [total, users] = await this.prisma.$transaction([
      this.prisma.user.count(),
      this.prisma.user.findMany({ skip, take: limit, include: { city: true } }),
    ]);

    const usersData = users.map(user => this.serializeUser(user));
    return { data: usersData, total, page, limit };
  }

  async promoteUser(adminId: number, targetUsername: string, promote: boolean) {
    const targetUser = await this.prisma.user.findUnique({ where: { username: targetUsername } });
    if (!targetUser) throw new NotFoundException('User not found');

    await this.prisma.user.update({
      where: { id: targetUser.id },
      data: { is_superuser: promote, is_staff: promote },
    });

    return { message: `User ${targetUser.username} has been ${promote ? 'promoted' : 'demoted'} to Superuser.` };
  }

  async deleteAccount(userId: number, data: DeleteAccountDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user || user.is_deleted) {
      throw new BadRequestException('Account already deleted.');
    }

    if (!data.password) throw new BadRequestException('Password is required.');
    const isPasswordValid = await bcrypt.compare(data.password, user.password);
    if (!isPasswordValid) throw new BadRequestException('Password is incorrect.');

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        is_deleted: true,
        deleted_at: new Date(),
        deleted_reason: data.reason,
        is_active: false,
      },
    });

    return { message: 'Account deleted successfully.' };
  }

  async updateLanguage(userId: number, data: LanguageUpdateDto) {
    if (!['ar', 'en'].includes(data.language)) {
      throw new BadRequestException("Invalid language choice. Use 'ar' or 'en'.");
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: { language: data.language },
    });

    return { message: 'Language updated successfully' };
  }

  async getUserProfile(username: string) {
    const user = await this.prisma.user.findUnique({ where: { username }, include: { city: true } });
    if (!user || user.is_deleted) throw new NotFoundException('User not found');

    return { data: this.serializeUser(user) };
  }

  // --- Password Reset Implementation ---
  async requestPasswordReset(data: PasswordResetRequestDto) {
    const user = await this.findUserByIdentifier(data.identifier);
    
    // We send success even if user not found to prevent user enumeration
    if (user && !user.is_deleted) {
      // Generate token
      const tokenString = Array.from({length: 6}, () => Math.floor(Math.random() * 10)).join('');
      
      await this.prisma.resetPasswordToken.create({
        data: {
          key: tokenString,
          user_id: user.id,
          created_at: new Date(),
          user_agent: 'API',
          ip_address: '127.0.0.1'
        }
      });

      if (user.email) {
        try {
          await this.mailerService.sendMail({
            to: user.email,
            subject: 'SolarHub Password Reset',
            text: `Your password reset token is: ${tokenString}`,
          });
        } catch (err) {
          console.error("Mail error: ", err);
          // In production we might not fail the request or we might
        }
      }
    }

    return { message: 'If the account exists, a password reset email has been sent.' };
  }

  async validateResetToken(data: PasswordResetTokenDto) {
    const token = await this.prisma.resetPasswordToken.findUnique({ where: { key: data.token } });
    if (!token) throw new BadRequestException('Invalid token.');

    // Assuming token valid for 24 hours
    const tokenAge = new Date().getTime() - new Date(token.created_at).getTime();
    if (tokenAge > 24 * 60 * 60 * 1000) {
      throw new BadRequestException('Token has expired.');
    }

    return { valid: true, message: 'Token is valid.' };
  }

  async confirmPasswordReset(data: PasswordResetConfirmDto) {
    const token = await this.prisma.resetPasswordToken.findUnique({ where: { key: data.token } });
    if (!token) throw new BadRequestException('Invalid token.');

    const tokenAge = new Date().getTime() - new Date(token.created_at).getTime();
    if (tokenAge > 24 * 60 * 60 * 1000) {
      throw new BadRequestException('Token has expired.');
    }

    const hashedPassword = await bcrypt.hash(data.password, 10);
    await this.prisma.user.update({
      where: { id: token.user_id },
      data: { password: hashedPassword },
    });

    // Delete used token
    await this.prisma.resetPasswordToken.delete({ where: { key: data.token } });

    return { message: 'Password reset successfully.' };
  }
}
