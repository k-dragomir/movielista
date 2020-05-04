DROP DATABASE IF EXISTS movielista;
CREATE DATABASE movielista;
USE `movielista`;

DROP TABLE IF EXISTS companies;
CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    company VARCHAR(200)
);

DROP TABLE IF EXISTS countries;
CREATE TABLE countries (
    id SERIAL PRIMARY KEY,
    country_rus VARCHAR(200),
    country_eng VARCHAR(200)
);

DROP TABLE IF EXISTS genres;
CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    genre_rus VARCHAR(200),
    genre_eng VARCHAR(200)
);

DROP TABLE IF EXISTS images;
CREATE TABLE images (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(200),
    path VARCHAR(200)
);

DROP TABLE IF EXISTS roles;
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    role_rus VARCHAR(200),
    role_eng VARCHAR(200)
);

DROP TABLE IF EXISTS title_types;
CREATE TABLE title_types (
    id SERIAL PRIMARY KEY,
    title_type_rus VARCHAR(200),
    title_type_eng VARCHAR(200)
);

-- ----------------------------------- USERS

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    signed_up_at TIMESTAMP DEFAULT now(),

    email VARCHAR(100) UNIQUE,
    phone_number BIGINT UNSIGNED UNIQUE,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(100)
);

DROP TABLE IF EXISTS user_profiles;
CREATE TABLE user_profiles (
    id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    updated_at TIMESTAMP DEFAULT now(),

    avatar BIGINT UNSIGNED,
    first_name VARCHAR(100) DEFAULT '',
    last_name VARCHAR(100) DEFAULT '',
    gender CHAR(1) DEFAULT '-',
    date_of_birth DATE DEFAULT NULL,
    country_id BIGINT UNSIGNED,
    about VARCHAR(350) DEFAULT '',

    is_private BIT DEFAULT 0,

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                           ON DELETE CASCADE -- Профиль удаляется при удалении пользователя
                           ON UPDATE CASCADE,
    FOREIGN KEY (`avatar`) REFERENCES `images`(`id`)
                           ON DELETE SET NULL
                           ON UPDATE CASCADE,
    FOREIGN KEY (`country_id`) REFERENCES `countries`(`id`)
                           ON DELETE SET NULL
                           ON UPDATE CASCADE
);

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    from_user BIGINT UNSIGNED,
    to_user BIGINT UNSIGNED,
    created_at TIMESTAMP DEFAULT now(),

    body_text TEXT NOT NULL,

    FOREIGN KEY (`from_user`) REFERENCES `users`(`id`)
                      ON DELETE SET NULL -- Сообщения остаются в диалоге при удалении одного из пользователей
                      ON UPDATE CASCADE ,
    FOREIGN KEY (`to_user`) REFERENCES `users`(`id`)
                      ON DELETE SET NULL -- Сообщения остаются в диалоге при удалении одного из пользователей
                      ON UPDATE CASCADE
);

-- ----------------------------------- TITLES

DROP TABLE IF EXISTS titles;
CREATE TABLE titles (
    id SERIAL PRIMARY KEY,
    title_rus VARCHAR(100) NOT NULL,
    title_eng VARCHAR(100) NOT NULL DEFAULT ''
);

DROP TABLE IF EXISTS title_info;
CREATE TABLE title_info (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    title_type_id BIGINT UNSIGNED,
    poster BIGINT UNSIGNED,
    country_id BIGINT UNSIGNED NOT NULL,
    tagline_rus VARCHAR(200) NOT NULL DEFAULT '',
    tagline_eng VARCHAR(200) NOT NULL DEFAULT '',
    synopsis_rus VARCHAR(500) NOT NULL DEFAULT '',
    synopsis_eng VARCHAR(500) NOT NULL DEFAULT '',
    release_date DATE NOT NULL,

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE ,
    FOREIGN KEY (`title_type_id`) REFERENCES `title_types`(`id`)
                        ON DELETE SET NULL
                        ON UPDATE CASCADE ,
    FOREIGN KEY (`poster`) REFERENCES `images`(`id`)
                        ON DELETE SET NULL
                        ON UPDATE CASCADE
);

DROP TABLE IF EXISTS series_info;
CREATE TABLE series_info (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    seasons SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    episodes MEDIUMINT UNSIGNED NOT NULL DEFAULT 1,
    conclude_date DATE,

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                         ON DELETE CASCADE
                         ON UPDATE CASCADE
);

DROP TABLE IF EXISTS movies_info;
CREATE TABLE movies_info (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    rars ENUM ('0+', '6+', '12+', '16+', '18+', 'NR') DEFAULT 'NR', -- Возрастная классификация информационной продукции
    mpaa ENUM ('G', 'PG', 'PG-13', 'R', 'NC-17', 'NR') DEFAULT 'NR', -- Система рейтингов Американской киноассоциации
    budget INT UNSIGNED DEFAULT 0,
    box_office INT UNSIGNED DEFAULT 0,
    viewership INT UNSIGNED DEFAULT 0,

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                         ON DELETE CASCADE
                         ON UPDATE CASCADE
);

-- ----------------------------------- TITLES ADDITIONAL INFO

DROP TABLE IF EXISTS title_country;
CREATE TABLE title_country (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    country_id BIGINT UNSIGNED,

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                         ON DELETE CASCADE
                         ON UPDATE CASCADE,
    FOREIGN KEY (`country_id`) REFERENCES `countries`(`id`)
                           ON DELETE SET NULL
                           ON UPDATE CASCADE
);

DROP TABLE IF EXISTS title_company;
CREATE TABLE title_company (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    company_id BIGINT UNSIGNED,

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                           ON DELETE CASCADE
                           ON UPDATE CASCADE ,
    FOREIGN KEY (`company_id`) REFERENCES `companies`(`id`)
                           ON DELETE SET NULL
                           ON UPDATE CASCADE
);

DROP TABLE IF EXISTS people;
CREATE TABLE people (
    id SERIAL PRIMARY KEY,
    first_name_rus VARCHAR(200),
    first_name_eng VARCHAR(200),
    last_name_rus VARCHAR(200),
    last_name_eng VARCHAR(200),
    date_of_birth DATE,
    date_of_death DATE DEFAULT NULL,
    photo BIGINT UNSIGNED,
    country_id BIGINT UNSIGNED,

    FOREIGN KEY (`photo`) REFERENCES `images`(`id`)
                            ON DELETE SET NULL
                            ON UPDATE CASCADE ,
    FOREIGN KEY (`country_id`) REFERENCES `countries`(`id`)
                            ON DELETE SET NULL
                            ON UPDATE CASCADE
);

DROP TABLE IF EXISTS title_cast_crew;
CREATE TABLE title_cast_crew (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    role_id BIGINT UNSIGNED,
    people_id BIGINT UNSIGNED,

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE ,
    FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`)
                            ON DELETE SET NULL
                            ON UPDATE CASCADE ,
    FOREIGN KEY (`people_id`) REFERENCES `people`(`id`)
                            ON DELETE SET NULL
                            ON UPDATE CASCADE
);

-- ----------------------------------- TITLES INFO, INFLUENCED BY USERS

DROP TABLE IF EXISTS keywords;
CREATE TABLE keywords (
    id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED,
    keyword VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                            ON DELETE SET NULL -- Ключевое слово остается даже после удаления пользователя
                            ON UPDATE CASCADE
);

DROP TABLE IF EXISTS title_keyword;
CREATE TABLE title_keyword (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    keyword_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED,
    vote BIT,
    created_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
    FOREIGN KEY (`keyword_id`) REFERENCES `keywords`(`id`)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                            ON DELETE SET NULL
                            ON UPDATE CASCADE
);

DROP TABLE IF EXISTS title_genre;
CREATE TABLE title_genre (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    genre_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED,
    vote BIT,
    created_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                         ON DELETE CASCADE
                         ON UPDATE CASCADE ,
    FOREIGN KEY (`genre_id`) REFERENCES `genres`(`id`)
                         ON DELETE CASCADE
                         ON UPDATE CASCADE ,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                         ON DELETE SET NULL
                         ON UPDATE CASCADE
);

DROP TABLE IF EXISTS rating;
CREATE TABLE rating (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED,
    rating TINYINT UNSIGNED NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                    ON DELETE CASCADE
                    ON UPDATE CASCADE ,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                    ON DELETE SET NULL
                    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED,
    body VARCHAR(500),
    is_positive BIT DEFAULT 1,
    created_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                     ON DELETE CASCADE
                     ON UPDATE CASCADE ,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                     ON DELETE SET NULL
                     ON UPDATE CASCADE
);

DROP TABLE IF EXISTS review_votes;
CREATE TABLE review_votes (
    id SERIAL PRIMARY KEY,
    review_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED,
    vote BIT,
    created_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`review_id`) REFERENCES `reviews`(`id`)
                          ON DELETE CASCADE
                          ON UPDATE CASCADE ,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                          ON DELETE SET NULL
                          ON UPDATE CASCADE
);

-- ----------------------------------- LISTS

DROP TABLE IF EXISTS watchlist;
CREATE TABLE watchlist (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                       ON DELETE CASCADE
                       ON UPDATE CASCADE ,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                       ON DELETE CASCADE
                       ON UPDATE CASCADE
);

DROP TABLE IF EXISTS is_seen;
CREATE TABLE is_seen (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                     ON DELETE CASCADE
                     ON UPDATE CASCADE ,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                     ON DELETE CASCADE
                     ON UPDATE CASCADE
);

DROP TABLE IF EXISTS user_lists;
CREATE TABLE user_lists (
    id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    list_name VARCHAR(50) DEFAULT '',
    description VARCHAR(100) DEFAULT '',
    is_private BIT DEFAULT 0,
    created_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE
);

DROP TABLE IF EXISTS user_list_items;
CREATE TABLE user_list_items (
    id SERIAL PRIMARY KEY,
    list_id BIGINT UNSIGNED NOT NULL,
    title_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`list_id`) REFERENCES `user_lists`(`id`)
                             ON DELETE CASCADE
                             ON UPDATE CASCADE ,
    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                             ON DELETE CASCADE
                             ON UPDATE CASCADE
);

-- ----------------------------------- FOLLOWERS

DROP TABLE IF EXISTS follow_user;
CREATE TABLE follow_user (
    id SERIAL PRIMARY KEY,
    follower_id BIGINT UNSIGNED NOT NULL,
    target_id BIGINT UNSIGNED NOT NULL,
    is_following BIT DEFAULT 1,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`follower_id`) REFERENCES `users`(`id`)
                             ON DELETE CASCADE
                             ON UPDATE CASCADE,
    FOREIGN KEY (`target_id`) REFERENCES `users`(`id`)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE
);

DROP TABLE IF EXISTS follow_keyword;
CREATE TABLE follow_keyword (
    id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    keyword_id BIGINT UNSIGNED NOT NULL,
    is_following BIT DEFAULT 1,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE ,
    FOREIGN KEY (`keyword_id`) REFERENCES `keywords`(`id`)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE
);

DROP TABLE IF EXISTS follow_genre;
CREATE TABLE follow_genre (
    id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    genre_id BIGINT UNSIGNED NOT NULL,
    is_following BIT DEFAULT 1,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                          ON DELETE CASCADE
                          ON UPDATE CASCADE ,
    FOREIGN KEY (`genre_id`) REFERENCES `genres`(`id`)
                          ON DELETE CASCADE
                          ON UPDATE CASCADE
);

DROP TABLE IF EXISTS follow_list;
CREATE TABLE follow_list (
    id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    list_id BIGINT UNSIGNED NOT NULL,
    is_following BIT DEFAULT 1,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
                         ON DELETE CASCADE
                         ON UPDATE CASCADE ,
    FOREIGN KEY (`list_id`) REFERENCES `user_lists`(`id`)
                         ON DELETE CASCADE
                         ON UPDATE CASCADE
);

-- ----------------------------------- GALLERIES

DROP TABLE IF EXISTS title_gallery;
CREATE TABLE title_gallery (
    id SERIAL PRIMARY KEY,
    title_id BIGINT UNSIGNED NOT NULL,
    image_id BIGINT UNSIGNED NOT NULL,

    FOREIGN KEY (`title_id`) REFERENCES `titles`(`id`)
                           ON DELETE CASCADE
                           ON UPDATE CASCADE,
    FOREIGN KEY (`image_id`) REFERENCES `images`(`id`)
                           ON DELETE CASCADE
                           ON UPDATE CASCADE
);

DROP TABLE IF EXISTS people_gallery;
CREATE TABLE people_gallery (
    id SERIAL PRIMARY KEY,
    people_id BIGINT UNSIGNED NOT NULL,
    image_id BIGINT UNSIGNED NOT NULL,

    FOREIGN KEY (`people_id`) REFERENCES `people`(`id`)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
    FOREIGN KEY (`image_id`) REFERENCES `images`(`id`)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE
);
