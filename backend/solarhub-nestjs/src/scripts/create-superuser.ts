import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import * as readline from 'readline';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const question = (query: string): Promise<string> =>
    new Promise((resolve) => rl.question(query, resolve));

  console.log('--- Create Superuser ---');
  const username = await question('Username: ');
  const email = await question('Email address: ');
  const password = await question('Password: ');
  
  // These were required fields in the old Django app
  const firstName = await question('First Name (optional): ');
  const lastName = await question('Last Name (optional): ');

  if (!username || !email || !password) {
    console.error('Error: Username, Email, and Password are required.');
    process.exit(1);
  }

  try {
    const existingUser = await prisma.user.findFirst({
      where: { OR: [{ username }, { email }] }
    });

    if (existingUser) {
      console.error('Error: A user with that username or email already exists.');
      process.exit(1);
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        username,
        email,
        password: hashedPassword,
        first_name: firstName || 'Admin',
        last_name: lastName || 'User',
        is_superuser: true,
        is_staff: true,
        is_active: true,
      },
    });

    console.log(`\nSuperuser created successfully!`);
    console.log(`Username: ${user.username}`);
    console.log(`Email: ${user.email}`);
    
  } catch (error) {
    console.error('\nError creating superuser:', error);
  } finally {
    rl.close();
    await app.close();
  }
}

bootstrap();
