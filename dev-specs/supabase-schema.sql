-- Create expense categories table
create table expense_categories (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  parent_id uuid references expense_categories(id),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create budgets table
create table budgets (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) not null,
  category_id uuid references expense_categories(id) not null,
  month date not null,
  allocated_amount decimal(10,2) not null default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  -- Composite unique constraint to prevent duplicate budgets
  unique(user_id, category_id, month)
);

-- Create RLS policies
alter table expense_categories enable row level security;
alter table budgets enable row level security;

-- Allow all authenticated users to read categories
create policy "Categories are viewable by authenticated users"
  on expense_categories for select
  to authenticated
  using (true);

-- Allow users to manage their own budgets
create policy "Users can manage their own budgets"
  on budgets for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
