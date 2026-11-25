-- جدول و سیاست‌های امنیتی برنامه «حساب» (قبلاً روی پروژه اجرا شده است)
create table if not exists public.hesab_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  y int not null, m int not null, d int not null,
  village text not null,
  area numeric not null default 0,
  unit_price numeric not null default 0,
  area_cost numeric not null default 0,
  rent numeric not null default 0,
  vehicle text not null default '',
  misc numeric not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists hesab_records_user_idx on public.hesab_records(user_id, y, m, d);
alter table public.hesab_records enable row level security;
create policy "hesab_select_own" on public.hesab_records for select to authenticated using (user_id = (select auth.uid()));
create policy "hesab_insert_own" on public.hesab_records for insert to authenticated with check (user_id = (select auth.uid()));
create policy "hesab_update_own" on public.hesab_records for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "hesab_delete_own" on public.hesab_records for delete to authenticated using (user_id = (select auth.uid()));

-- دسترسی جدول برای کاربران واردشده (بدون آن خطای permission denied می‌دهد)
grant usage on schema public to authenticated;
grant select, insert, update, delete on table public.hesab_records to authenticated;
revoke all on table public.hesab_records from anon;

-- لیست انتظار، لیست نوبت و نام شخص در رکوردها
alter table public.hesab_records add column if not exists person text not null default '';
create table if not exists public.hesab_waiting (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null, village text not null default '', phone text not null default '',
  created_at timestamptz not null default now()
);
create table if not exists public.hesab_turns (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null, village text not null default '', phone text not null default '',
  y int not null, m int not null, d int not null,
  created_at timestamptz not null default now()
);
create index if not exists hesab_waiting_user_idx on public.hesab_waiting(user_id);
create index if not exists hesab_turns_user_idx on public.hesab_turns(user_id, y, m, d);
alter table public.hesab_waiting enable row level security;
alter table public.hesab_turns enable row level security;
create policy "hw_select_own" on public.hesab_waiting for select to authenticated using (user_id = (select auth.uid()));
create policy "hw_insert_own" on public.hesab_waiting for insert to authenticated with check (user_id = (select auth.uid()));
create policy "hw_update_own" on public.hesab_waiting for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "hw_delete_own" on public.hesab_waiting for delete to authenticated using (user_id = (select auth.uid()));
create policy "ht_select_own" on public.hesab_turns for select to authenticated using (user_id = (select auth.uid()));
create policy "ht_insert_own" on public.hesab_turns for insert to authenticated with check (user_id = (select auth.uid()));
create policy "ht_update_own" on public.hesab_turns for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "ht_delete_own" on public.hesab_turns for delete to authenticated using (user_id = (select auth.uid()));
grant select, insert, update, delete on table public.hesab_waiting to authenticated;
grant select, insert, update, delete on table public.hesab_turns to authenticated;
revoke all on table public.hesab_waiting from anon;
revoke all on table public.hesab_turns from anon;

-- واریز به همکار
create table if not exists public.hesab_payouts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null, card text not null default '', amount numeric not null default 0,
  y int not null, m int not null, d int not null,
  receipt text not null default '',
  created_at timestamptz not null default now()
);
create index if not exists hesab_payouts_user_idx on public.hesab_payouts(user_id, y, m, d);
alter table public.hesab_payouts enable row level security;
create policy "hp_select_own" on public.hesab_payouts for select to authenticated using (user_id = (select auth.uid()));
create policy "hp_insert_own" on public.hesab_payouts for insert to authenticated with check (user_id = (select auth.uid()));
create policy "hp_update_own" on public.hesab_payouts for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "hp_delete_own" on public.hesab_payouts for delete to authenticated using (user_id = (select auth.uid()));
grant select, insert, update, delete on table public.hesab_payouts to authenticated;
revoke all on table public.hesab_payouts from anon;

-- نوع واریز، هزینه وسایل و تنظیمات (هزینه متراژ نهایی دستی)
alter table public.hesab_payouts add column if not exists kind text not null default 'c';
create table if not exists public.hesab_equip (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  note text not null default '', amount numeric not null default 0,
  created_at timestamptz not null default now()
);
create table if not exists public.hesab_kv (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  key text not null, value text not null default '',
  primary key (user_id, key)
);
create index if not exists hesab_equip_user_idx on public.hesab_equip(user_id);
alter table public.hesab_equip enable row level security;
alter table public.hesab_kv enable row level security;
create policy "he_select_own" on public.hesab_equip for select to authenticated using (user_id = (select auth.uid()));
create policy "he_insert_own" on public.hesab_equip for insert to authenticated with check (user_id = (select auth.uid()));
create policy "he_update_own" on public.hesab_equip for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "he_delete_own" on public.hesab_equip for delete to authenticated using (user_id = (select auth.uid()));
create policy "hk_select_own" on public.hesab_kv for select to authenticated using (user_id = (select auth.uid()));
create policy "hk_insert_own" on public.hesab_kv for insert to authenticated with check (user_id = (select auth.uid()));
create policy "hk_update_own" on public.hesab_kv for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "hk_delete_own" on public.hesab_kv for delete to authenticated using (user_id = (select auth.uid()));
grant select, insert, update, delete on table public.hesab_equip to authenticated;
grant select, insert, update, delete on table public.hesab_kv to authenticated;
revoke all on table public.hesab_equip from anon;
revoke all on table public.hesab_kv from anon;

-- وضعیت واریز هر رکورد
alter table public.hesab_records add column if not exists paid boolean not null default false;
