import { inject } from '@angular/core';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { Subscription } from '@btg-funds-manager/contracts';
import { FundService } from '../services/fund.service';
import { AuthStore } from './auth.store';

type SubscriptionsState = {
  subscriptions: Subscription[];
  loading: boolean;
  error: string | null;
  unsubscriptionMessage: string | null;
};

const initialState: SubscriptionsState = {
  subscriptions: [],
  loading: false,
  error: null,
  unsubscriptionMessage: null,
};

export const SubscriptionsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),
  withMethods(
    (store, fundService = inject(FundService), authStore = inject(AuthStore)) => ({
      async loadSubscriptions() {
        const userId = authStore.uid();
        if (!userId) return;

        patchState(store, { loading: true, error: null });
        try {
          const subscriptions = await fundService.getUserSubscriptions(userId);
          patchState(store, { subscriptions, loading: false });
        } catch (err: any) {
          patchState(store, { loading: false, error: err.message });
        }
      },
      
      async unsubscribeFromFund(subscriptionId: string) {
        const userId = authStore.uid();
        if (!userId) return;

        patchState(store, { loading: true, error: null, unsubscriptionMessage: null });
        try {
          const result = await fundService.unsubscribeFromFund(userId, subscriptionId);
          patchState(store, { loading: false, unsubscriptionMessage: result.message });
          // Reload subscriptions after success
          await this.loadSubscriptions();
        } catch (err: any) {
          patchState(store, { loading: false, error: err.message });
        }
      },
      
      clearUnsubscriptionMessage() {
        patchState(store, { unsubscriptionMessage: null });
      }
    })
  )
);
