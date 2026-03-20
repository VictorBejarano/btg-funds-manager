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
  templateUrl: './funds.component.html',
  styleUrl: './funds.component.scss'
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
    this.userStore.reloadProfile();
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
