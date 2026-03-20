import { Injectable, inject } from '@angular/core';
import { Functions, httpsCallable } from '@angular/fire/functions';
import { Fund, Subscription, FundSubscriptionData } from '@btg-funds-manager/contracts';

@Injectable({
  providedIn: 'root'
})
export class FundService {
  private functions = inject(Functions);

  async getFunds(userId?: string): Promise<Fund[]> {
    const callable = httpsCallable<any, Fund[]>(this.functions, 'getfunds');
    const result = await callable({ userId });
    return result.data;
  }

  async subscribeToFund(data: FundSubscriptionData): Promise<{ message: string }> {
    const callable = httpsCallable<FundSubscriptionData, { message: string }>(this.functions, 'subscribefund');
    const result = await callable(data);
    return result.data;
  }

  async unsubscribeFromFund(userId: string, subscriptionId: string): Promise<{ message: string }> {
    const callable = httpsCallable<any, { message: string }>(this.functions, 'unsubscribefund');
    const result = await callable({ userId, subscriptionId });
    return result.data;
  }

  async getUserSubscriptions(userId: string): Promise<Subscription[]> {
    const callable = httpsCallable<any, Subscription[]>(this.functions, 'getusersubscriptions');
    const result = await callable({ userId });
    return result.data;
  }
}
