-- enums
-- https://www.reddit.com/r/pkmntcg/comments/8bjpu1/color_identity_in_pkmntcg/
-- create type tcg_type as enum ('grass', 'fire', 'water', 'lightning', 'psychic', 'fighting', 'darkness', 'metal', 'dragon', 'colorless');
create type energy as enum ('grass', 'fire', 'water', 'lightning', 'psychic', 'fighting', 'darkness', 'metal', 'dragon', 'colorless');

create type rpg_type as enum ('normal', 'fire', 'water', 'electric', 'grass', 'ice', 'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug', 'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy', 'stellar');
create type trainer as enum ('item', 'pokemon_tool', 'fossil', 'supporter');
-- alter type vg_type rename to rpg_type;
create type rarity as enum ('promo', 'dia1', 'dia2', 'dia3', 'dia4', 'star1', 'star2', 'star3', 'crown');
-- promo -- common, uncommon, rare, double_rare, art_rare, super_rare, immserive_rare, crown_rare

create type operator as enum ('+', '*');

-- domains
create domain generation as integer check (value between 1 and 9);
create domain stage as integer check (value in (0, 1, 2));

-- tables

create table tcg_type
(
    id    integer primary key,
    name  varchar not null,
    color varchar not null
);

create table pokemon
(
    id             integer generated always as identity primary key,
    dex_no         integer        not null, -- 전국 도감 번호(0025); not unique in the case of Rotom
    species        varchar        not null, -- 'Mouse Pokémon'
    identifier     varchar unique not null, -- e.g. 'nidoran-m', 'farfetchd'. Used as a URL path variable(kebab-case)
    name           varchar unique not null, -- Original Eng. name(= display_name); e.g. 'Nidoran♂' (U+2642) or "Farfetch'd".
    type1          rpg_type       not null,
    type2          rpg_type,                -- 두번째 타입은 없을 수도 있다
    height         integer,                 -- 40(cm)
    weight         integer,                 -- 6000(g)
    introduced_gen generation,
    unique (dex_no, name)
);
-- 1:n -> 한 포켓몬은 여러 포켓몬 카드에 속할 수 있음

create table description
(
    id         integer generated always as identity primary key,
    content    text    not null,
    pokemon_id integer unique references pokemon (id) on delete set null on update cascade
);

create table illustrator
(
    id   integer generated always as identity primary key,
    name varchar unique not null
);

create table attack
(
    id          integer generated always as identity primary key,
    name        varchar unique not null, -- 'Thunderbolt'
    damage      integer,                 -- 140
    energies    energy[]     not null, -- ['lightning'::energy, 'lightning'::energy, 'lightning'::energy]
    description text,                    -- 'Discard all Energy from this Pokémon.'
    operator    operator
);

create table expansion
(
    id         integer primary key,
    title      varchar     not null, -- 'Genetic Apex'
    alias      varchar     not null, -- 'PROMO-A', 'A1', 'A1a', 'A2'
    series     varchar,              -- 'A'
    code       varchar     not null, -- 'P-A', 'A1', 'A1a', 'A2'
    releasedAt timestamptz not null
);
-- PROMO-A는 아이디를 0으로 한다
-- 1:n -> 한 확장팩은 여러 부스터팩을 가질 수 있음

create table booster_pack
(
    id           integer primary key,
    expansion_id integer references expansion (id) not null, -- n:1 -> 여러 부스터팩이 한 확장팩에 속함
    name         varchar                           not null, -- 'Mewtwo', 'Pikachu', 'Charizard'
    count        integer                           not null  -- 동적으로 계산하지 말고 트리거로 미리 계산된 값을 사용
);

create table ability
(
    id          integer generated always as identity primary key,
    name        varchar unique not null, -- 'Shell Armor'
    description text                     -- 'This Pokémon takes -10 damage from attacks.'
);

create table card
(
    id             integer generated always as identity primary key,
    identifier     varchar unique not null, -- internal_name e.g. 'nidoran-m', 'farfetchd'. Used as a URL path variable(kebab-case)
    name           varchar unique not null, -- Original Eng. name(= display_name); e.g. 'Nidoran♂' (U+2642) or "Farfetch'd".
    card_no        integer unique not null, -- Card number within the booster pack (e.g., 0026).
    rarity         rarity         not null,
    point          integer,
    offering_rate  numeric(6, 3),
    img_url        varchar,
    illustrator_id integer references illustrator (id)
);

create table pokemon_card
(
    card_id        integer references card (id) on delete cascade primary key,
    stage          stage                            not null, -- 0, 1, 2 진화 상태('Basic', 'Stage 1', 'Stage 2') 대신 숫자로 사용
    hp             integer                          not null, -- 120
    type_id        integer references tcg_type (id) not null, -- n:1 -> 여러 포켓몬 카드가 하나의 타입을 공유할 수 있음
    attack1        integer references attack (id)   not null, -- n:1 -> 여러 포켓몬 카드가 하나의 첫번째 공격 기술을 참조함
    attack2        integer references attack (id),            -- n:1 -> 여러 포켓몬 카드가 하나의 두번째 공격 기술을 참조할 수 있음(nullable)
    retreat        energy[]                       not null, -- ['colorless'::type, 'colorless'::type] -- retreat은 type보단 개수가 중요하고 조회용으로만 사용되므로 배열 사용
    weakness       integer references tcg_type (id) not null, -- n:1(type_id와 동일)
    ex_rule        text,                                      -- 'When your Pokémon ex is Knocked Out, your opponents gets 2 points.' 이 값이 존재하면 ex pokemon이므로 boolean처럼 사용. ex_text 값은 항상 같은 것 같다
    -- n:1 -> 여러 포켓몬 카드가 한 포켓몬으로부터 진화할 수 있음, 화석 포켓몬에 대한 예외처리 필요
    -- pokemon_id 참조하는 원리와 같음
    evolves_from   integer references pokemon (id),
    ability_id     integer references ability (id),
    pokemon_id     integer references pokemon (id)  not null, -- n:1 -> 여러 포켓몬 카드가 하나의 포켓몬을 참조할 수 있음
    description_id integer references description (id)
);


-- create table booster_pack_pokemon_card
-- (
--     booster_pack_id integer references booster_pack (id)      not null,
--     pokemon_card_id integer references pokemon_card (id)      not null,
--     card_no         integer references pokemon_card (card_no) not null,
--     primary key (booster_pack_id, pokemon_card_id),
--     unique (booster_pack_id, card_no)
-- );

-- 포켓몬 트레이너를 뜻하는 게 아니라 트레이너가(= 플레이어) 사용하는 카드
create table trainer_card
(
    card_id     integer references card (id) on delete cascade primary key,
    kind        trainer not null, -- 'item', 'Pokémon Tool', 'Fossil', 'Supporter'
    description text    not null, -- trainer_card는 description이 겹치는 경우는 동일한 서포터 카드에 일러스트만 다른 경우밖에 없기 때문에 별도 테이블을 두지 않음
    footnote    text
);

create table fossil_card
(
    trainer_card_id integer references trainer_card (card_id) on delete cascade primary key,
    hp              integer not null
);

create table promo_card
(
    card_id       integer references card (id) on delete cascade primary key,
    how_to_obtain text
);

create table cards_join_booster_packs
(
    card_id         integer references card (id)         not null,
    card_no         integer references card (card_no)    not null,
    booster_pack_id integer references booster_pack (id) not null,
    primary key (card_id, booster_pack_id),
    unique (card_no, booster_pack_id)
);

-- create table booster_pack_trainer_card
-- (
--     booster_pack_id integer references booster_pack (id)      not null,
--     trainer_card_id integer references trainer_card (id)      not null,
--     card_no         integer references trainer_card (card_no) not null,
--     primary key (booster_pack_id, trainer_card_id),
--     unique (booster_pack_id, card_no)
-- );


create table deck
(
    id              integer generated always as identity primary key,
    name            varchar not null, -- 22자 제한(not unique in the game)
    deck_box        energy,
    energy1         energy not null,
    energy2         energy,
    highlight_cards integer[],                                 -- references card (id[])
    user_id            integer references "user" (id) on delete cascade not null,
--     pokemon_card_id integer references pokemon_card (card_id), -- 동일한 포켓몬인지 구분하는 방법 고민(피카츄가 2마리여도 ex면 추가가 가능하다)
--     trainer_card_id integer references trainer_card (card_id)  -- trainer는 이름이 같으면 2개 중복을 비허용
);

create table deck_cards
(
    deck_id integer references deck (id) on delete cascade not null,
    card_id integer references card (id) on delete set null
    -- quantity 컬럼을 두면 쿼리가 복잡해지고, 안 두면 제약조건을 걸 수가 없다(insert할 때마다 개수검사)
    -- 그냥 application 레벨에서 개수 검사하는걸로
);

create table user
(
    id              integer generated always as identity primary key
    -- not yet implemented
);
--
-- create table users_join_decks
-- (
--
-- );

-- todo: user, i18n, deck, draft, trigger, pgsql, varchar/text size