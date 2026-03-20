import { inject } from '@angular/core';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { Fund, FundSubscriptionData } from '@btg-funds-manager/contracts';
import { FundService } from '../services/fund.service';
import { AuthStore } from './auth.store';

type FundsState = {
  funds: Fund[];
  loading: boolean;
  error: string | null;
  subscriptionMessage: string | null;
};

const initialState: FundsState = {
  funds: [],
  loading: false,
  error: null,
  subscriptionMessage: null,
};

export const FundsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),
  withMethods(
    (store, fundService = inject(FundService), authStore = inject(AuthStore)) => ({
      async loadFunds() {
        patchState(store, { loading: true, error: null });
        try {
          // get the current user id to filter out subscribed funds (as the function does)
          const userId = authStore.uid() ?? undefined;
          const funds = await fundService.getFunds(userId);
          patchState(store, { funds, loading: false });
        } catch (err: any) {
          patchState(store, { loading: false, error: err.message });
        }
      },
      
      async subscribeToFund(data: FundSubscriptionData) {
        patchState(store, { loading: true, error: null, subscriptionMessage: null });
        try {
          const result = await fundService.subscribeToFund(data);
          patchState(store, { loading: false, subscriptionMessage: result.message });
          // After a successful subscription, reload funds to reflect the new available list
          await this.loadFunds();
        } catch (err: any) {
          patchState(store, { loading: false, error: err.message });
        }
      },
      
      clearSubscriptionMessage() {
        patchState(store, { subscriptionMessage: null });
      }
    })
  )
);
