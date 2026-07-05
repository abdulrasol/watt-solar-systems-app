import { Injectable, OnModuleInit } from '@nestjs/common';
import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getMessaging, Messaging } from 'firebase-admin/messaging';
import * as path from 'path';
import * as fs from 'fs';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private _messaging: Messaging | null = null;

  onModuleInit() {
    const serviceAccountPath = path.resolve(process.cwd(), 'fcm-service-account.json');
    if (fs.existsSync(serviceAccountPath)) {
      const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
      
      if (!getApps().length) {
        const app = initializeApp({
          credential: cert(serviceAccount),
        });
        this._messaging = getMessaging(app);
        console.log('Firebase Admin initialized successfully.');
      }
    } else {
      console.warn('fcm-service-account.json not found! Firebase Admin not initialized.');
    }
  }

  get messaging() {
    return this._messaging;
  }
}
