import { Injectable, CanActivate, ExecutionContext, ForbiddenException, UnauthorizedException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector, private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    
    // If no roles are required, we let it pass. The JwtAuthGuard handles authentication.
    if (!requiredRoles) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;
    
    if (!user) {
      throw new UnauthorizedException('User not authenticated');
    }

    // Company endpoints usually pass 'company-id' in the header.
    const companyIdStr = request.headers['company-id'];
    if (!companyIdStr) {
      throw new ForbiddenException('Missing company-id header');
    }
    
    const companyId = parseInt(companyIdStr, 10);
    if (isNaN(companyId)) {
      throw new ForbiddenException('Invalid company-id header');
    }

    const member = await this.prisma.companyMember.findFirst({
      where: { user_id: user.id, company_id: companyId },
    });

    if (!member) {
      throw new ForbiddenException('You are not a member of this company');
    }

    // Check if member's role matches any of the required roles
    if (!requiredRoles.includes(member.role)) {
      throw new ForbiddenException(`You do not have the required role. Required: ${requiredRoles.join(', ')}`);
    }

    // Attach company and member to request for convenience in controllers/services
    request.member = member;
    request.companyId = companyId;

    return true;
  }
}
