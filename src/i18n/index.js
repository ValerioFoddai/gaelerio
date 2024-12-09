import { createI18n } from 'vue-i18n'

const messages = {
  en: {
    nav: {
      assets: 'Assets',
      analytics: 'Analytics', 
      transactions: 'Transactions',
      settings: 'Settings'
    },
    auth: {
      signIn: 'Sign in to your account',
      signUp: 'Create your account',
      email: 'Email address',
      password: 'Password',
      confirmPassword: 'Confirm password',
      login: 'Sign in',
      register: 'Sign up',
      forgotPassword: 'Forgot your password?',
      noAccount: "Don't have an account?",
      hasAccount: 'Already have an account?',
      resetPassword: 'Reset your password',
      updatePassword: 'Update your password',
      passwordRequirement: 'Password must be at least 6 characters',
      resetLink: 'Send reset link',
      update: 'Update password',
      error: {
        login: 'Failed to sign in',
        register: 'Failed to create account',
        reset: 'Failed to send reset link',
        update: 'Failed to update password',
        passwordLength: 'Password must be at least 6 characters',
        passwordMatch: 'Passwords do not match'
      },
      success: {
        reset: 'Reset link sent to your email',
        update: 'Password updated successfully'
      }
    },
    transactions: {
      title: 'Transactions',
      new: {
        title: 'New Transaction',
        description: 'Create a new transaction by filling out the form below.',
        error: 'Failed to create transaction'
      },
      date: 'Date',
      category: 'Category',
      subcategory: 'Subcategory',
      amount: 'Amount',
      description: 'Description',
      selectCategory: 'Select category',
      selectSubcategory: 'Select subcategory',
      delete: {
        title: 'Delete Transaction',
        message: 'Are you sure you want to delete this transaction? This action cannot be undone.'
      }
    },
    settings: {
      title: 'Settings',
      general: 'General',
      categories: {
        title: 'Expense Categories',
        italiano: 'Categorie di spesa'
      },
      tags: {
        title: 'Tags',
        empty: {
          title: 'No tags',
          description: 'Get started by creating a new tag.',
          action: 'Create Tag'
        },
        add: {
          title: 'Add Tag',
          category: 'Add Category',
          subcategory: 'Add Sub Tag'
        },
        edit: {
          title: 'Edit {type}',
          category: 'Category',
          subcategory: 'Subcategory'
        },
        delete: {
          title: 'Delete {type}',
          message: 'Are you sure you want to delete this {type}? This action cannot be undone.',
          success: '{type} deleted successfully',
          error: 'Failed to delete {type}'
        },
        name: 'Name'
      },
      notifications: 'Notifications'
    },
    common: {
      cancel: 'Cancel',
      save: 'Save',
      saving: 'Saving...',
      delete: 'Delete',
      edit: 'Edit',
      create: 'Create'
    }
  },
  it: {
    nav: {
      assets: 'Patrimonio',
      analytics: 'Analisi',
      transactions: 'Transazioni', 
      settings: 'Impostazioni'
    },
    auth: {
      signIn: 'Accedi al tuo account',
      signUp: 'Crea il tuo account',
      email: 'Indirizzo email',
      password: 'Password',
      confirmPassword: 'Conferma password',
      login: 'Accedi',
      register: 'Registrati',
      forgotPassword: 'Password dimenticata?',
      noAccount: 'Non hai un account?',
      hasAccount: 'Hai già un account?',
      resetPassword: 'Reimposta la password',
      updatePassword: 'Aggiorna la password',
      passwordRequirement: 'La password deve contenere almeno 6 caratteri',
      resetLink: 'Invia link di reset',
      update: 'Aggiorna password',
      error: {
        login: 'Accesso fallito',
        register: 'Registrazione fallita',
        reset: 'Invio link di reset fallito',
        update: 'Aggiornamento password fallito',
        passwordLength: 'La password deve contenere almeno 6 caratteri',
        passwordMatch: 'Le password non coincidono'
      },
      success: {
        reset: 'Link di reset inviato alla tua email',
        update: 'Password aggiornata con successo'
      }
    },
    transactions: {
      title: 'Transazioni',
      new: {
        title: 'Nuova Transazione',
        description: 'Crea una nuova transazione compilando il modulo sottostante.',
        error: 'Creazione transazione fallita'
      },
      date: 'Data',
      category: 'Categoria',
      subcategory: 'Sottocategoria',
      amount: 'Importo',
      description: 'Descrizione',
      selectCategory: 'Seleziona categoria',
      selectSubcategory: 'Seleziona sottocategoria',
      delete: {
        title: 'Elimina Transazione',
        message: 'Sei sicuro di voler eliminare questa transazione? Questa azione non può essere annullata.'
      }
    },
    settings: {
      title: 'Impostazioni',
      general: 'Generale',
      categories: {
        title: 'Categorie di spesa'
      },
      tags: {
        title: 'Tag',
        empty: {
          title: 'Nessun tag',
          description: 'Inizia creando un nuovo tag.',
          action: 'Crea Tag'
        },
        add: {
          title: 'Aggiungi Tag',
          category: 'Aggiungi Categoria',
          subcategory: 'Aggiungi Sub Tag'
        },
        edit: {
          title: 'Modifica {type}',
          category: 'Categoria',
          subcategory: 'Sottocategoria'
        },
        delete: {
          title: 'Elimina {type}',
          message: 'Sei sicuro di voler eliminare questo {type}? Questa azione non può essere annullata.',
          success: '{type} eliminato con successo',
          error: 'Eliminazione {type} fallita'
        },
        name: 'Nome'
      },
      notifications: 'Notifiche'
    },
    common: {
      cancel: 'Annulla',
      save: 'Salva',
      saving: 'Salvataggio...',
      delete: 'Elimina',
      edit: 'Modifica',
      create: 'Crea'
    }
  }
}

const i18n = createI18n({
  legacy: false,
  locale: 'en',
  fallbackLocale: 'en',
  messages
})

export default i18n