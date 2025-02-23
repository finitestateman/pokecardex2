-- enums
create type tcg_type as enum ('grass', 'fire', 'water', 'lightning', 'psychic', 'fighting', 'darkness', 'metal', 'dragon', 'colorless');
create type rpg_type as enum ('normal', 'fire', 'water', 'electric', 'grass', 'ice', 'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug', 'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy', 'stellar');
create type trainer as enum ('item', 'pokemon_tool', 'fossil', 'supporter');
-- alter type vg_type rename to rpg_type;
create type rarity as enum ( 'd1', 'd2', 'd3', 'd4', 's1', 's2', 's3', 'c');
-- promo -- common, uncommon, rare, double_rare, art_rare, super_rare, immserive_rare, crown_rare

create type operator as enum ('+', '*');

-- domains
create domain generation as integer check (value between 1 and 9);
create domain stage as integer check (value in (0, 1, 2));

-- tables
create table pokemon (
    id uuid default gen_random_uuid() primary key,
    dex_no integer not null, -- 전국 도감 번호(0025)
    species varchar not null, -- 'Mouse Pokémon'
    name varchar not null, -- 'Pikachu'
    type1 rpg_type not null, -- 'electric'::lightning
    type2 rpg_type, -- 두번째 타입은 없을 수도 있다
    height integer, -- 40(cm)
    weight integer, -- 6000(g)
    introduced_gen generation
);
-- 1:n -> 한 포켓몬은 여러 포켓몬 카드에 속할 수 있음

create table description (
    id integer generated always as identity primary key,
    content text not null,
    pokemon_id uuid references pokemon(id) on delete set null on update cascade
);

create table illustrator
(
    id integer generated always as identity primary key,
    name varchar not null
);

create table attack (
    id integer generated always as identity primary key,
    name varchar unique not null, -- 'Thunderbolt'
    damage integer not null, -- 140
    energies tcg_type[] not null, -- ['lightning'::tcg_type, 'lightning'::tcp_type, 'lightning'::tcg_type]
    description text, -- 'Discard all Energy from this Pokémon.'
    operator operator
);

create table expansion (
    id integer primary key,
    title varchar not null, -- 'Genetic Apex'
    alias varchar not null, -- 'PROMO-A', 'A1', 'A1a', 'A2'
    series varchar, -- 'A'
    code varchar not null, -- 'P-A', 'A1', 'A1a', 'A2'
    releasedAt timestamptz not null
);
-- PROMO-A는 아이디를 0으로 한다
-- 1:n -> 한 확장팩은 여러 부스터팩을 가질 수 있음

create table booster_pack (
    id integer primary key,
    expansion_id integer references expansion(id) not null, -- n:1 -> 여러 부스터팩이 한 확장팩에 속함
    name varchar not null, -- 'Mewtwo', 'Pikachu', 'Charizard'
    count integer not null -- 동적으로 계산하지 말고 트리거로 미리 계산된 값을 사용
);

create table ability (
    id integer generated always as identity primary key,
    name varchar unique not null, -- 'Shell Armor'
    description text -- 'This Pokémon takes -10 damage from attacks.'
);


create table pokemon_card (
    id uuid default gen_random_uuid() primary key,
    name varchar not null, -- 'Raichu', 'Pikachu ex'
    card_no integer unique not null, -- 0026 카드가 속한 부스터팩 내부에서의 번호
    stage stage not null, -- 0, 1, 2 진화 상태('Basic', 'Stage 1', 'Stage 2') 대신 숫자로 사용
    hp integer not null, -- 120
    type tcg_type not null, -- 'lightning'::tcg_type
    attack1 integer references attack(id) not null, -- n:1 -> 여러 포켓몬 카드가 하나의 첫번째 공격 기술을 참조함
    attack2 integer references attack(id), -- n:1 -> 여러 포켓몬 카드가 하나의 두번째 공격 기술을 참조할 수 있음(nullable)
    rarity rarity not null,
    retreat tcg_type[] not null, -- ['colorless'::tcg_type, 'colorless'::tcg_type]
    weakness tcg_type not null,
    offering_rate numeric(6,3) not null,
    illustrator_id integer references illustrator(id),
    ex_rule text, -- 'When your Pokémon ex is Knocked Out, your opponents gets 2 points.' 이 값이 존재하면 ex pokemon이므로 boolean처럼 사용. ex_text 값은 항상 같은 것 같다
    -- n:1 -> 여러 포켓몬 카드가 한 포켓몬으로부터 진화할 수 있음, 화석 포켓몬에 대한 예외처리 필요
    -- pokemon_id 참조하는 원리와 같음
    evolves_from uuid references pokemon(id),
    ability_id integer references ability(id),
    pokemon_id uuid references pokemon(id) not null, -- n:1 -> 여러 포켓몬 카드가 하나의 포켓몬을 참조할 수 있음
    description_id integer references description(id)
);

create table pack_point (
    id uuid references pokemon_card(id) primary key,
    point integer
);

create table booster_pack_pokemon_card (
    booster_pack_id integer references booster_pack(id) not null,
    pokemon_card_id uuid references pokemon_card(id) not null,
    card_no integer references pokemon_card(card_no) not null,
    primary key (booster_pack_id, pokemon_card_id),
    unique (booster_pack_id, card_no)
);

create table trainer_card (
    id uuid default gen_random_uuid() primary key,
    kind trainer not null,
    name varchar unique not null,
    description text not null,
    rarity rarity,
    footnote text,
    illustrator_id integer references illustrator(id)
);

create table fossil_card (
    trainer_card_id uuid primary key references trainer_card(id) on delete cascade,
    hp integer not null
);

create table promo_card (
    id integer generated always as identity primary key,
    pokemon_card_id uuid references pokemon_card(id) on delete cascade,
    trainer_card_id uuid references trainer_card(id) on delete cascade,
    how_to_obtain text,
    unique (pokemon_card_id, trainer_card_id)
);
