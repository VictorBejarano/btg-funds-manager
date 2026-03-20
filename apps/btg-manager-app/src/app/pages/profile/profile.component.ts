import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { UserNotificationMethod, Transaction } from '@btg-funds-manager/contracts';
import { UserStore } from '../../state/user.store';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss'
})
export class ProfileComponent implements OnInit {
  userStore = inject(UserStore);
  fb = inject(FormBuilder);

  isEditing = false;
  profileForm: FormGroup;

  // Transaction detail modal state
  selectedTransaction: Transaction | null = null;
  isTransactionModalOpen = false;

  constructor() {
    this.profileForm = this.fb.group({
      name: ['', Validators.required],
      lastname: ['', Validators.required],
      phone: [''],
      availableBalance: [0, Validators.required],
      notificationMethod: [UserNotificationMethod.Email],
    });
  }

  ngOnInit() {
    this.userStore.reloadProfile();
  }

  getInitials(): string {
    const name = this.userStore.user()?.name || '';
    if (!name) return 'U';
    return name.charAt(0).toUpperCase();
  }

  openEditModal() {
    const user = this.userStore.user();
    if (user) {
      this.profileForm.patchValue({
        name: user.name,
        lastname: user.lastname,
        phone: user.phone || '',
        availableBalance: user.availableBalance,
        notificationMethod: user.notificationMethod || UserNotificationMethod.Email,
      });
      this.isEditing = true;
    }
  }

  closeEditModal() {
    this.isEditing = false;
  }

  async saveProfile() {
    if (this.profileForm.valid) {
      const updatedData = this.profileForm.getRawValue();
      await this.userStore.updateUserData(updatedData);
      
      if (!this.userStore.error()) {
        this.closeEditModal();
      }
    }
  }

  openTransactionModal(tx: Transaction) {
    this.selectedTransaction = tx;
    this.isTransactionModalOpen = true;
  }

  closeTransactionModal() {
    this.selectedTransaction = null;
    this.isTransactionModalOpen = false;
  }
}
