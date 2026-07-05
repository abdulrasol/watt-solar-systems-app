import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, UseInterceptors, UploadedFile } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { AppConfigService } from '../app-config.service';
import { FeedbackFormDto, FeedbackUpdateFormDto } from '../dto/feedback.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';
import { diskStorage } from 'multer';
import * as path from 'path';

@ApiTags('Feedbacks')
@Controller()
export class FeedbackController {
  constructor(private readonly configService: AppConfigService) {}

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Get('feedbacks')
  async listFeedbacks() {
    return this.configService.listFeedbacks();
  }

  @Post('feedbacks')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('attachment', {
    storage: diskStorage({
      destination: './uploads/feedbacks',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
      }
    })
  }))
  async createFeedback(@Body() data: FeedbackFormDto, @UploadedFile() image: Express.Multer.File) {
    return this.configService.createFeedback(data, image ? image.path : undefined);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Put('feedback/s:id') // Maintained typo for backward compatibility as noted
  async updateFeedback(@Param('id') id: number, @Body() data: FeedbackUpdateFormDto) {
    return this.configService.updateFeedback(Number(id), data);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Delete('feedback/:id')
  async deleteFeedback(@Param('id') id: number) {
    return this.configService.deleteFeedback(Number(id));
  }
}
