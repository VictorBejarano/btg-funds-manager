import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { UserStore } from '../../state/user.store';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-header">
      <div>
        <h1>Profile & History</h1>
        <p>Your account details and transaction history.</p>
      </div>
      <button class="refresh-btn" (click)="userStore.reloadProfile()">
        Refresh 🔄
      </button>
    </div>

    <div class="profile-container">
      
      <!-- User Profile Card -->
      <section class="profile-card">
        <div class="card-header">
          <h2>Account Details</h2>
        </div>
        
        <div class="loading-state" *ngIf="userStore.loading()">
           <div class="loader-sm"></div>
        </div>

        <div class="profile-details" *ngIf="!userStore.loading() && userStore.user()">
           <div class="detail-group">
             <div class="avatar-lg">{{ getInitials() }}</div>
             <div class="user-meta">
               <h3>{{ userStore.user()?.name }}</h3>
             </div>
           </div>

           <div class="balance-display">
             <div class="balance-label">Total Balance available</div>
             <div class="balance-amount">{{ (userStore.user()?.availableBalance ?? 0) | currency:'COP':'symbol':'1.0-0' }}</div>
           </div>
        </div>
      </section>

      <!-- Transaction History -->
      <section class="history-card">
        <div class="card-header">
          <h2>Transaction History</h2>
        </div>

        <div class="loading-state" *ngIf="userStore.loading()">
           <div class="loader-sm"></div>
           <p>Loading transactions...</p>
        </div>

        <div class="empty-state" *ngIf="!userStore.loading() && userStore.transactions().length === 0">
           <p>No transactions found.</p>
        </div>

        <div class="transactions-list" *ngIf="!userStore.loading() && userStore.transactions().length > 0">
           <div class="transaction-item" *ngFor="let tx of userStore.transactions()">
             <div class="tx-icon" [ngClass]="tx.type === 'subscribe' ? 'icon-sub' : 'icon-unsub'">
                {{ tx.type === 'subscribe' ? '⬇️' : '⬆️' }}
             </div>
             
             <div class="tx-details">
               <h4>{{ tx.type === 'subscribe' ? 'Subscribed to' : 'Cancelled' }} {{ tx.fundName }}</h4>
               <span class="tx-date">{{ tx.createdAt | date:'medium' }}</span>
             </div>

             <div class="tx-amount" [ngClass]="tx.type === 'subscribe' ? 'amount-negative' : 'amount-positive'">
               {{ tx.type === 'subscribe' ? '-' : '+' }} {{ tx.amount | currency:'COP':'symbol':'1.0-0' }}
             </div>
           </div>
        </div>
      </section>

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

    .profile-container {
      display: flex;
      flex-direction: column;
      gap: 2rem;
    }

    .card-header {
      margin-bottom: 1.5rem;
      h2 {
        font-size: 1.25rem;
        margin: 0;
        color: #f8fafc;
      }
    }

    .profile-card, .history-card {
      background: rgba(15, 23, 42, 0.6);
      border: 1px solid rgba(255, 255, 255, 0.05);
      border-radius: 16px;
      padding: 2rem;
    }

    .profile-details {
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      align-items: center;
      gap: 2rem;
      background: rgba(0, 0, 0, 0.2);
      padding: 1.5rem;
      border-radius: 12px;
    }

    .detail-group {
      display: flex;
      align-items: center;
      gap: 1.5rem;
    }

    .avatar-lg {
      width: 72px;
      height: 72px;
      border-radius: 50%;
      background: linear-gradient(135deg, #38bdf8, #3b82f6);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 2rem;
      font-weight: 700;
      color: white;
      box-shadow: 0 10px 25px -5px rgba(59, 130, 246, 0.4);
    }

    .user-meta h3 {
      font-size: 1.5rem;
      margin: 0;
      color: #f8fafc;
    }

    .balance-display {
      text-align: right;
    }

    .balance-label {
      font-size: 0.875rem;
      color: #94a3b8;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      margin-bottom: 0.5rem;
    }

    .balance-amount {
      font-size: 2.25rem;
      font-weight: 700;
      color: #10b981;
    }

    .transactions-list {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    .transaction-item {
      display: flex;
      align-items: center;
      padding: 1.25rem;
      background: rgba(0, 0, 0, 0.2);
      border: 1px solid rgba(255, 255, 255, 0.03);
      border-radius: 12px;
      transition: background 0.2s;

      &:hover {
        background: rgba(255, 255, 255, 0.05);
      }
    }

    .tx-icon {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: flex;
      justify-content: center;
      align-items: center;
      font-size: 1.5rem;
      margin-right: 1.5rem;

      &.icon-sub {
        background: rgba(239, 68, 68, 0.1);
      }

      &.icon-unsub {
        background: rgba(16, 185, 129, 0.1);
      }
    }

    .tx-details {
      flex: 1;

      h4 {
        margin: 0 0 0.25rem;
        font-size: 1rem;
        color: #f8fafc;
      }

      .tx-date {
        font-size: 0.875rem;
        color: #64748b;
      }
    }

    .tx-amount {
      font-size: 1.125rem;
      font-weight: 600;

      &.amount-negative {
        color: #ef4444;
      }

      &.amount-positive {
        color: #10b981;
      }
    }

    .loading-state, .empty-state {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 3rem 0;

      p { color: #94a3b8; margin-top: 1rem; }
    }

    .loader-sm {
      border: 3px solid rgba(56, 189, 248, 0.1);
      width: 24px;
      height: 24px;
      border-radius: 50%;
      border-left-color: #38bdf8;
      animation: spin 1s linear infinite;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  `]
})
export class ProfileComponent implements OnInit {
  userStore = inject(UserStore);

  ngOnInit() {
    this.userStore.reloadProfile();
  }

  getInitials(): string {
    const name = this.userStore.user()?.name || '';
    if (!name) return 'U';
    return name.charAt(0).toUpperCase();
  }
}
