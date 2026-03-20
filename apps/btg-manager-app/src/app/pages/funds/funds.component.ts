import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FundsStore } from '../../state/funds.store';
import { AuthStore } from '../../state/auth.store';
import { UserStore } from '../../state/user.store';
import { Fund } from '@btg-funds-manager/contracts';

@Component({
  selector: 'app-funds',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="page-header">
      <div>
        <h1>Available Funds</h1>
        <p>Discover and subscribe to top-performing funds tailored for you.</p>
      </div>
      <button class="refresh-btn" (click)="fundsStore.loadFunds()">
        Refresh 🔄
      </button>
    </div>

    <!-- Alert Messages -->
    <div class="alert alert-error" *ngIf="fundsStore.error()">
      <strong>Error:</strong> {{ fundsStore.error() }}
      <button class="close-btn" (click)="fundsStore.loadFunds()">×</button>
    </div>

    <div class="alert alert-success" *ngIf="fundsStore.subscriptionMessage()">
      {{ fundsStore.subscriptionMessage() }}
      <button class="close-btn" (click)="fundsStore.clearSubscriptionMessage()">×</button>
    </div>

    <div class="loading-state" *ngIf="fundsStore.loading()">
      <div class="loader-lg"></div>
      <p>Loading available funds...</p>
    </div>

    <div class="empty-state" *ngIf="!fundsStore.loading() && fundsStore.funds().length === 0">
      <div class="empty-icon">📂</div>
      <h3>No funds available</h3>
      <p>You may be subscribed to all available funds already, or none are currently offered.</p>
    </div>

    <div class="funds-grid" *ngIf="!fundsStore.loading() && fundsStore.funds().length > 0">
      <div class="fund-card" *ngFor="let fund of fundsStore.funds()">
        <div class="card-header">
          <div class="fund-category">{{ fund.category }}</div>
          <div class="min-amount">Min: {{ fund.minInvestment | currency:'COP':'symbol':'1.0-0' }}</div>
        </div>
        
        <h3 class="fund-name">{{ fund.name }}</h3>
        
        <div class="fund-actions">
          <input 
            type="number" 
            [(ngModel)]="subscriptionAmounts[fund.id]" 
            placeholder="Amount to invest" 
            class="amount-input"
            [min]="fund.minInvestment"
          />
          <button 
            class="action-btn" 
            [disabled]="isSubscribing || !isValidAmount(fund)"
            (click)="subscribe(fund)"
          >
             {{ isSubscribing ? 'Processing...' : 'Subscribe' }}
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
      background: rgba(56, 189, 248, 0.1);
      color: #38bdf8;
      padding: 0.25rem 0.75rem;
      border-radius: 20px;
      font-size: 0.75rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .min-amount {
      font-size: 0.875rem;
      color: #94a3b8;
    }

    .fund-name {
      font-size: 1.25rem;
      color: #f8fafc;
      margin: 0 0 1.5rem;
      line-height: 1.4;
      flex: 1;
    }

    .fund-actions {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
    }

    .amount-input {
      width: 100%;
      background: rgba(0, 0, 0, 0.2);
      border: 1px solid rgba(255, 255, 255, 0.1);
      padding: 0.75rem 1rem;
      border-radius: 10px;
      color: white;
      font-family: inherit;
      box-sizing: border-box;

      &:focus {
        outline: none;
        border-color: #38bdf8;
      }
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

      &:hover:not(:disabled) {
        background: #2563eb;
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
export class FundsComponent implements OnInit {
  fundsStore = inject(FundsStore);
  authStore = inject(AuthStore);
  userStore = inject(UserStore); // to trigger profile reload when subscribed

  // Local state to keep track of amounts entered for each fund by ID
  subscriptionAmounts: { [key: string]: number } = {};
  isSubscribing = false; // Add to prevent double clicks

  ngOnInit() {
    this.fundsStore.loadFunds();
  }

  isValidAmount(fund: Fund): boolean {
    const amount = this.subscriptionAmounts[fund.id];
    return amount != null && amount >= fund.minInvestment;
  }

  async subscribe(fund: Fund) {
    if (!this.isValidAmount(fund)) return;
    
    const userId = this.authStore.uid();
    if (!userId) {
       alert("User is not authenticated");
       return;
    }

    this.isSubscribing = true;
    const amount = this.subscriptionAmounts[fund.id];
    
    await this.fundsStore.subscribeToFund({
      fundId: fund.id,
      amount,
      userId
    });

    this.isSubscribing = false;
    
    // Clear input after success OR error
    this.subscriptionAmounts[fund.id] = 0;

    // Refresh user balance in header natively
    if (this.fundsStore.subscriptionMessage()) {
      await this.userStore.loadUserData();
    }
  }
}
