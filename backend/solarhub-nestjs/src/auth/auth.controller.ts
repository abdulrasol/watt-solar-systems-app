import { Controller, Post, Body, Get, Put, UseGuards, Param, Query, HttpCode } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { UpdateProfileDto, LanguageUpdateDto, DeleteAccountDto } from './dto/profile.dto';
import { PasswordResetRequestDto, PasswordResetTokenDto, PasswordResetConfirmDto } from './dto/password.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { SuperuserGuard } from './guards/superuser.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';

@ApiTags('Auth & Users')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(200)
  @ApiOperation({ summary: 'Login' })
  async login(@Body() body: LoginDto) {
    return this.authService.login(body);
  }

  @Post('register')
  @HttpCode(200)
  @ApiOperation({ summary: 'Register new user' })
  async register(@Body() body: RegisterDto) {
    return this.authService.register(body);
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  async getProfile(@CurrentUser() user: any) {
    return this.authService.getProfile(user.id);
  }

  @Put('profile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update current user profile' })
  async updateProfile(@CurrentUser() user: any, @Body() body: UpdateProfileDto) {
    return this.authService.updateProfile(user.id, body);
  }

  @Get()
  @UseGuards(SuperuserGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'List all users (Superuser only)' })
  async getUsers(@Query('page') page: string = '1', @Query('limit') limit: string = '12') {
    return this.authService.getUsers(Number(page), Number(limit));
  }

  @Post('promote/:username')
  @HttpCode(200)
  @UseGuards(SuperuserGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Promote user to superuser (Superuser only)' })
  async promoteUser(@CurrentUser() user: any, @Param('username') username: string, @Body('promote') promote: boolean) {
    return this.authService.promoteUser(user.id, username, promote);
  }

  @Post('delete-account')
  @HttpCode(200)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Soft delete current account' })
  async deleteAccount(@CurrentUser() user: any, @Body() body: DeleteAccountDto) {
    return this.authService.deleteAccount(user.id, body);
  }

  @Post('password-reset')
  @HttpCode(200)
  @ApiOperation({ summary: 'Request password reset email' })
  async requestPasswordReset(@Body() body: PasswordResetRequestDto) {
    return this.authService.requestPasswordReset(body);
  }

  @Post('password-reset/validate-token')
  @HttpCode(200)
  @ApiOperation({ summary: 'Validate password reset token' })
  async validateResetToken(@Body() body: PasswordResetTokenDto) {
    return this.authService.validateResetToken(body);
  }

  @Post('password-reset/confirm')
  @HttpCode(200)
  @ApiOperation({ summary: 'Confirm password reset with token' })
  async confirmPasswordReset(@Body() body: PasswordResetConfirmDto) {
    return this.authService.confirmPasswordReset(body);
  }

  @Put('language')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update user language' })
  async updateLanguage(@CurrentUser() user: any, @Body() body: LanguageUpdateDto) {
    return this.authService.updateLanguage(user.id, body);
  }

  @Get(':username')
  @ApiOperation({ summary: 'Get public user profile' })
  async getUserProfile(@Param('username') username: string) {
    return this.authService.getUserProfile(username);
  }
}
