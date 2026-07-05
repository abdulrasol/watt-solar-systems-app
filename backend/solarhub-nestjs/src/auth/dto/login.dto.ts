import { IsString, IsNotEmpty, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
    @ApiProperty({
        description: 'Username, Email, or Mobile number',
        example: 'ali_ahmed'
    })
    @IsString()
    @IsNotEmpty({ message: 'الرجاء إدخال اسم المستخدم، البريد الإلكتروني أو رقم الهاتف' })
    identifier: string; // The user requested mobile, email or username

    @ApiProperty({
        description: 'Password',
        example: 'password123'
    })
    @IsString()
    //   @MinLength(6, { message: 'كلمة المرور غير صحيحة' })
    password: string;
}