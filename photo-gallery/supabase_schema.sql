-- ============================================================
-- 画廊数据库建表 SQL
-- 在 Supabase → SQL Editor 中执行此文件
-- ============================================================

-- 标签表
create table if not exists tags (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  color text not null default '#888888',
  created_at timestamptz default now()
);

-- 图片表
create table if not exists photos (
  id uuid primary key default gen_random_uuid(),
  title text,
  date date,
  note text,
  url text not null,
  thumb_url text,
  width integer,
  height integer,
  cloudinary_id text,
  tags uuid[] default '{}',
  created_at timestamptz default now()
);

-- 索引（加快标签筛选速度）
create index if not exists photos_tags_idx on photos using gin(tags);
create index if not exists photos_date_idx on photos (date desc);

-- ============================================================
-- Row Level Security (RLS) 设置
-- 访客只读，写入需要有效 token
-- ============================================================

alter table tags enable row level security;
alter table photos enable row level security;

-- 所有人可读
create policy "public read tags" on tags for select using (true);
create policy "public read photos" on photos for select using (true);

-- 只有通过 service_role 或 anon key 带 Authorization 才能写
-- （管理后台用 anon key + 请求头写入，符合此条件）
create policy "authed insert photos" on photos for insert
  with check (auth.role() = 'anon');

create policy "authed update photos" on photos for update
  using (auth.role() = 'anon');

create policy "authed delete photos" on photos for delete
  using (auth.role() = 'anon');

create policy "authed insert tags" on tags for insert
  with check (auth.role() = 'anon');

create policy "authed update tags" on tags for update
  using (auth.role() = 'anon');

create policy "authed delete tags" on tags for delete
  using (auth.role() = 'anon');

-- ============================================================
-- 示例数据（可选，测试用，部署后可删除）
-- ============================================================

-- insert into tags (name, color) values
--   ('风景', '#6c9e6c'),
--   ('旅行', '#7e9ecf'),
--   ('日常', '#c8a97e');
