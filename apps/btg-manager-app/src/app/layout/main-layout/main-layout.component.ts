import { Component, inject, OnInit, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { AuthStore } from '../../state/auth.store';
import { UserStore } from '../../state/user.store';

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <div class="app-layout">
      <!-- Sidebar / Navigation -->
      <aside class="sidebar">
        <div class="sidebar-header">
          <div class="logo">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
               <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
            </svg>
            <span>BTG Manager</span>
          </div>
        </div>
        
        <nav class="nav-links">
          <a routerLink="/funds" routerLinkActive="active" class="nav-link">
            <span class="icon">📈</span> Available Funds
          </a>
          <a routerLink="/subscriptions" routerLinkActive="active" class="nav-link">
             <span class="icon">💼</span> My Subscriptions
          </a>
          <a routerLink="/profile" routerLinkActive="active" class="nav-link">
             <span class="icon">👤</span> Profile & History
          </a>
        </nav>

        <div class="sidebar-footer">
           <button class="logout-btn" (click)="logout()">
              <span class="icon">🚪</span> Logout
           </button>
        </div>
      </aside>

      <!-- Main Content -->
      <main class="main-content">
        <!-- Top Header -->
        <header class="top-header">
          <div class="header-title">
             <!-- Could show context or welcome msg here -->
          </div>
          
          <div class="user-balance-widget">
            <div class="balance-info">
              <span class="balance-label">Current Balance</span>
              <span class="balance-amount" *ngIf="!userStore.loading()">
                {{ (userStore.user()?.availableBalance ?? 0) | currency:'COP':'symbol':'1.0-0' }}
              </span>
              <span class="balance-amount loading-text" *ngIf="userStore.loading()">Loading...</span>
            </div>
            <div class="avatar">
               {{ getInitials() }}
            </div>
          </div>
        </header>

        <!-- Router Outlet for Pages -->
        <div class="page-container">
           <router-outlet></router-outlet>
        </div>
      </main>
    </div>
  `,
  styles: [`
    .app-layout {
      display: flex;
      height: 100vh;
      background-color: #0b0f19;
      color: #e2e8f0;
      font-family: 'Inter', system-ui, sans-serif;
      overflow: hidden;
    }

    .sidebar {
      width: 260px;
      background: rgba(15, 23, 42, 0.95);
      border-right: 1px solid rgba(255, 255, 255, 0.05);
      display: flex;
      flex-direction: column;
      z-index: 10;
    }

    .sidebar-header {
      padding: 1.5rem;
      border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    }

    .logo {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      font-size: 1.25rem;
      font-weight: 700;
      color: #f8fafc;
      
      svg {
        width: 28px;
        height: 28px;
        color: #38bdf8;
      }
    }

    .nav-links {
      flex: 1;
      padding: 1.5rem 1rem;
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    .nav-link {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0.875rem 1rem;
      border-radius: 12px;
      color: #94a3b8;
      text-decoration: none;
      font-weight: 500;
      transition: all 0.2s;

      &:hover {
        background: rgba(255, 255, 255, 0.03);
        color: #f8fafc;
      }

      &.active {
        background: linear-gradient(135deg, rgba(56, 189, 248, 0.1), rgba(59, 130, 246, 0.1));
        color: #38bdf8;
        border: 1px solid rgba(56, 189, 248, 0.2);
      }
    }

    .sidebar-footer {
      padding: 1.5rem;
      border-top: 1px solid rgba(255, 255, 255, 0.05);
    }

    .logout-btn {
      width: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
      background: transparent;
      border: 1px solid rgba(239, 68, 68, 0.2);
      color: #ef4444;
      padding: 0.75rem;
      border-radius: 12px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: rgba(239, 68, 68, 0.1);
        border-color: rgba(239, 68, 68, 0.4);
      }
    }

    .main-content {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow-y: auto;
      background-image: radial-gradient(circle at top right, #111827 0%, #0b0f19 50%);
    }

    .top-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 1.25rem 2rem;
      background: rgba(11, 15, 25, 0.8);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border-bottom: 1px solid rgba(255, 255, 255, 0.05);
      position: sticky;
      top: 0;
      z-index: 5;
    }

    .user-balance-widget {
      display: flex;
      align-items: center;
      gap: 1.25rem;
      background: rgba(15, 23, 42, 0.6);
      padding: 0.5rem 0.5rem 0.5rem 1.25rem;
      border-radius: 50px;
      border: 1px solid rgba(255, 255, 255, 0.05);
    }

    .balance-info {
      display: flex;
      flex-direction: column;
      align-items: flex-end;
    }

    .balance-label {
      font-size: 0.75rem;
      color: #64748b;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .balance-amount {
      font-size: 1.125rem;
      font-weight: 700;
      color: #10b981;

      &.loading-text {
        font-size: 0.875rem;
        color: #94a3b8;
      }
    }

    .avatar {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: linear-gradient(135deg, #38bdf8, #3b82f6);
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 600;
      color: white;
      box-shadow: 0 4px 10px rgba(59, 130, 246, 0.3);
    }

    .page-container {
      flex: 1;
      padding: 2rem;
      max-width: 1200px;
      margin: 0 auto;
      width: 100%;
      box-sizing: border-box;
    }
  `]
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
