import { Component, inject, OnInit, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { AuthStore } from '../../state/auth.store';
import { UserStore } from '../../state/user.store';

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './main-layout.component.html',
  styleUrl: './main-layout.component.scss'
})
export class MainLayoutComponent implements OnInit {
  authStore = inject(AuthStore);
  userStore = inject(UserStore);
  router = inject(Router);

  constructor() {
    effect(() => {
      // If user logs out, redirect to login
      if (!this.authStore.uid()) {
        this.router.navigate(['/login']);
      }
    });
  }

  ngOnInit() {
    // Load initial user data for the header balance
    this.userStore.loadUserData();
  }

  async logout() {
    await this.authStore.logout();
  }

  getInitials(): string {
    const name = this.userStore.user()?.name || '';
    if (!name) return 'U';
    return name.charAt(0).toUpperCase();
  }
}
