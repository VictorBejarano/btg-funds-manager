import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SubscriptionsStore } from '../../state/subscriptions.store';
import { UserStore } from '../../state/user.store';

@Component({
  selector: 'app-subscriptions',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './subscriptions.component.html',
  styleUrl: './subscriptions.component.scss'
})
export class SubscriptionsComponent implements OnInit {
  subscriptionsStore = inject(SubscriptionsStore);
  userStore = inject(UserStore);

  isUnsubscribing: string | null = null;

  ngOnInit() {
    this.subscriptionsStore.loadSubscriptions();
  }

  async unsubscribe(subscriptionId: string) {
    if(!confirm("Are you sure you want to cancel this subscription? The amount will be refunded to your balance.")) {
      return;
    }

    this.isUnsubscribing = subscriptionId;
    
    await this.subscriptionsStore.unsubscribeFromFund(subscriptionId);

    this.isUnsubscribing = null;
    
    if (this.subscriptionsStore.unsubscriptionMessage()) {
      // Reload user profile data to update balance
      await this.userStore.loadUserData();
    }
  }
}
