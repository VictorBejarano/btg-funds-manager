import { inject } from '@angular/core';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { User, Transaction } from '@btg-funds-manager/contracts';
import { UserService } from '../services/user.service';
import { AuthStore } from './auth.store';

type UserState = {
  user: User | null;
  transactions: Transaction[];
  loading: boolean;
  error: string | null;
};

const initialState: UserState = {
  user: null,
  transactions: [],
  loading: false,
  error: null,
};

export const UserStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),
  withMethods(
    (store, userService = inject(UserService), authStore = inject(AuthStore)) => ({
      async loadUserData() {
        const userId = authStore.uid();
        if (!userId) {
          patchState(store, { user: null });
          return;
        }

        patchState(store, { loading: true, error: null });
        try {
          const user = await userService.getUserData(userId);
          patchState(store, { user, loading: false });
        } catch (err: any) {
          patchState(store, { loading: false, error: err.message });
        }
      },
      
      async loadTransactions() {
        const userId = authStore.uid();
        if (!userId) {
          patchState(store, { transactions: [] });
          return;
        }

        patchState(store, { loading: true, error: null });
        try {
          const transactions = await userService.getUserTransactions(userId);
          patchState(store, { transactions, loading: false });
        } catch (err: any) {
          patchState(store, { loading: false, error: err.message });
        }
      },

      // Convenience method to reload both
      async reloadProfile() {
        await Promise.all([this.loadUserData(), this.loadTransactions()]);
      }
    })
  )
);
