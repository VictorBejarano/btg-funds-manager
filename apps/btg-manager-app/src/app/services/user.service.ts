import { Injectable, inject } from '@angular/core';
import { Functions, httpsCallable } from '@angular/fire/functions';
import { User, Transaction } from '@btg-funds-manager/contracts';

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private functions = inject(Functions);

  async getUserData(userId: string): Promise<User> {
    const callable = httpsCallable<any, User>(this.functions, 'getuserdata');
    const result = await callable({ userId });
    return result.data;
  }

  async updateUserData(userId: string, userData: Partial<User>): Promise<{ message: string }> {
    const callable = httpsCallable<any, { message: string }>(this.functions, 'updateuserdata');
    const result = await callable({ userId, userData });
    return result.data;
  }

  async getUserTransactions(userId: string): Promise<Transaction[]> {
    const callable = httpsCallable<any, Transaction[]>(this.functions, 'getusertransactions');
    const result = await callable({ userId });
    return result.data;
  }
}
