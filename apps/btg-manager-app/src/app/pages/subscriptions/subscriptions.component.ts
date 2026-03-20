import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SubscriptionsStore } from '../../state/subscriptions.store';
import { UserStore } from '../../state/user.store';

@Component({
  selector: 'app-subscriptions',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-header">
      <div>
        <h1>My Subscriptions</h1>
        <p>Manage your active fund investments.</p>
      </div>
      <button class="refresh-btn" (click)="subscriptionsStore.loadSubscriptions()">
        Refresh 🔄
      </button>
    </div>

    <!-- Alert Messages -->
    <div class="alert alert-error" *ngIf="subscriptionsStore.error()">
      <strong>Error:</strong> {{ subscriptionsStore.error() }}
      <button class="close-btn" (click)="subscriptionsStore.loadSubscriptions()">×</button>
    </div>

    <div class="alert alert-success" *ngIf="subscriptionsStore.unsubscriptionMessage()">
      {{ subscriptionsStore.unsubscriptionMessage() }}
      <button class="close-btn" (click)="subscriptionsStore.clearUnsubscriptionMessage()">×</button>
    </div>

    <div class="loading-state" *ngIf="subscriptionsStore.loading()">
      <div class="loader-lg"></div>
      <p>Loading your subscriptions...</p>
    </div>

    <div class="empty-state" *ngIf="!subscriptionsStore.loading() && subscriptionsStore.subscriptions().length === 0">
      <div class="empty-icon">📂</div>
      <h3>No Active Subscriptions</h3>
      <p>You haven't subscribed to any funds yet. Head over to Available Funds to start investing.</p>
    </div>

    <div class="funds-grid" *ngIf="!subscriptionsStore.loading() && subscriptionsStore.subscriptions().length > 0">
      <div class="fund-card" *ngFor="let sub of subscriptionsStore.subscriptions()">
        <div class="card-header">
          <div class="fund-category">Active</div>
        </div>
        
        <h3 class="fund-name">{{ sub.fundName }}</h3>
        
        <div class="subscription-details">
          <div class="detail-row">
            <span class="detail-label">Invested Amount:</span>
            <span class="detail-value">{{ sub.amount | currency:'COP':'symbol':'1.0-0' }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Date:</span>
            <span class="detail-value">{{ sub.createdAt | date:'medium' }}</span>
          </div>
        </div>

        <div class="fund-actions">
          <button 
            class="action-btn danger-btn" 
            [disabled]="isUnsubscribing === sub.id"
            (click)="unsubscribe(sub.id)"
          >
             {{ isUnsubscribing === sub.id ? 'Processing...' : 'Cancel Subscription' }}
          </button>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .page-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-end;
      margin-bottom: 2.5rem;

      h1 {
        font-size: 2rem;
        margin: 0 0 0.5rem;
        color: #f8fafc;
        letter-spacing: -0.025em;
      }

      p {
        color: #94a3b8;
        margin: 0;
      }
    }

    .refresh-btn {
      background: rgba(30, 41, 59, 1);
      border: 1px solid rgba(255, 255, 255, 0.1);
      color: #cbd5e1;
      padding: 0.5rem 1rem;
      border-radius: 8px;
      cursor: pointer;
      font-size: 0.875rem;
      font-weight: 500;
      transition: all 0.2s;

      &:hover {
        background: rgba(51, 65, 85, 1);
        color: white;
      }
    }

    .alert {
      padding: 1rem 1.25rem;
      border-radius: 12px;
      margin-bottom: 1.5rem;
      display: flex;
      justify-content: space-between;
      align-items: center;

      &.alert-error {
        background: rgba(239, 68, 68, 0.1);
        border: 1px solid rgba(239, 68, 68, 0.2);
        color: #fca5a5;
      }

      &.alert-success {
        background: rgba(16, 185, 129, 0.1);
        border: 1px solid rgba(16, 185, 129, 0.2);
        color: #6ee7b7;
      }

      .close-btn {
        background: transparent;
        border: none;
        color: inherit;
        font-size: 1.25rem;
        cursor: pointer;
        line-height: 1;
        opacity: 0.7;
        padding: 0 0.5rem;

        &:hover { opacity: 1; }
      }
    }

    .loading-state, .empty-state {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 5rem 0;
      background: rgba(15, 23, 42, 0.4);
      border: 1px dashed rgba(255, 255, 255, 0.1);
      border-radius: 20px;

      p { color: #94a3b8; margin-top: 1rem; }
      h3 { color: #f8fafc; margin-bottom: 0.5rem; font-size: 1.25rem; }
    }

    .empty-icon {
      font-size: 3rem;
      margin-bottom: 1rem;
    }

    .loader-lg {
      border: 4px solid rgba(56, 189, 248, 0.1);
      width: 40px;
      height: 40px;
      border-radius: 50%;
      border-left-color: #38bdf8;
      animation: spin 1s linear infinite;
    }

    .funds-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 1.5rem;
    }

    .fund-card {
      background: rgba(15, 23, 42, 0.6);
      border: 1px solid rgba(255, 255, 255, 0.05);
      border-radius: 16px;
      padding: 1.5rem;
      transition: transform 0.2s, box-shadow 0.2s;
      display: flex;
      flex-direction: column;

      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3);
        border-color: rgba(56, 189, 248, 0.2);
      }
    }

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 1rem;
    }

    .fund-category {
      background: rgba(16, 185, 129, 0.1);
      color: #10b981;
      padding: 0.25rem 0.75rem;
      border-radius: 20px;
      font-size: 0.75rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .fund-name {
      font-size: 1.25rem;
      color: #f8fafc;
      margin: 0 0 1rem;
      line-height: 1.4;
      flex: 1;
    }

    .subscription-details {
      background: rgba(0, 0, 0, 0.2);
      border-radius: 10px;
      padding: 1rem;
      margin-bottom: 1.5rem;
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    .detail-row {
      display: flex;
      justify-content: space-between;
      font-size: 0.875rem;
    }

    .detail-label {
      color: #94a3b8;
    }

    .detail-value {
      color: #e2e8f0;
      font-weight: 500;
    }

    .fund-actions {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
      margin-top: auto;
    }

    .action-btn {
      background: #3b82f6;
      color: white;
      border: none;
      padding: 0.75rem;
      border-radius: 10px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s;

      &.danger-btn {
        background: transparent;
        border: 1px solid rgba(239, 68, 68, 0.5);
        color: #ef4444;

        &:hover:not(:disabled) {
          background: rgba(239, 68, 68, 0.1);
          border-color: #ef4444;
        }
      }

      &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  `]
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
