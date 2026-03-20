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
  
  // Modal state
  isCancelModalOpen = false;
  selectedSubscriptionId: string | null = null;

  ngOnInit() {
    this.subscriptionsStore.loadSubscriptions();
  }

  openCancelModal(subscriptionId: string) {
    this.selectedSubscriptionId = subscriptionId;
    this.isCancelModalOpen = true;
  }

  closeCancelModal() {
    this.isCancelModalOpen = false;
    this.selectedSubscriptionId = null;
  }

  async confirmUnsubscribe() {
    if (!this.selectedSubscriptionId) return;

    this.isUnsubscribing = this.selectedSubscriptionId;
    const subId = this.selectedSubscriptionId;
    this.closeCancelModal();
    
    await this.subscriptionsStore.unsubscribeFromFund(subId);

    this.isUnsubscribing = null;
    
    if (this.subscriptionsStore.unsubscriptionMessage()) {
      // Reload user profile data to update balance
      await this.userStore.loadUserData();
    }
  }
}
