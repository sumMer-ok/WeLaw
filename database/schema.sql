-- EnofLaw Database Schema
-- Common Law Learning Platform Database Design

-- Create Database
CREATE DATABASE IF NOT EXISTS enoflaw CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE enoflaw;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(200) UNIQUE,
    password_hash VARCHAR(255),
    avatar VARCHAR(500),
    settings JSON,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Folders Table
CREATE TABLE IF NOT EXISTS folders (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    parent_id VARCHAR(36),
    icon VARCHAR(50),
    color VARCHAR(20),
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    FOREIGN KEY (parent_id) REFERENCES folders(id) ON DELETE CASCADE,
    INDEX idx_parent (parent_id),
    INDEX idx_created_by (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Cases Table
CREATE TABLE IF NOT EXISTS cases (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    citation VARCHAR(200),
    court VARCHAR(200),
    judgment_date DATE,
    parties JSON,
    case_number VARCHAR(100),
    judges JSON,
    full_text TEXT,
    summary TEXT,
    key_facts JSON,
    holding TEXT,
    reasoning TEXT,
    ai_analysis JSON,
    folder_id VARCHAR(36),
    tags JSON,
    category VARCHAR(100),
    status VARCHAR(50),
    priority VARCHAR(20),
    file_path VARCHAR(500),
    file_type VARCHAR(20),
    page_count INT,
    word_count INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    INDEX idx_folder (folder_id),
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_judgment_date (judgment_date),
    FULLTEXT INDEX idx_fulltext (full_text, title) WITH PARSER ngram
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Annotations Table
CREATE TABLE IF NOT EXISTS annotations (
    id VARCHAR(36) PRIMARY KEY,
    case_id VARCHAR(36) NOT NULL,
    type VARCHAR(50) NOT NULL,
    position JSON NOT NULL,
    content TEXT,
    color VARCHAR(20),
    tags JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    FOREIGN KEY (case_id) REFERENCES cases(id) ON DELETE CASCADE,
    INDEX idx_case (case_id),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Annotation Replies Table
CREATE TABLE IF NOT EXISTS annotation_replies (
    id VARCHAR(36) PRIMARY KEY,
    annotation_id VARCHAR(36) NOT NULL,
    content TEXT NOT NULL,
    parent_id VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    FOREIGN KEY (annotation_id) REFERENCES annotations(id) ON DELETE CASCADE,
    INDEX idx_annotation (annotation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vocabulary Table
CREATE TABLE IF NOT EXISTS vocabulary (
    id VARCHAR(36) PRIMARY KEY,
    term VARCHAR(200) NOT NULL,
    pronunciation VARCHAR(200),
    audio_url VARCHAR(500),
    part_of_speech VARCHAR(50),
    difficulty VARCHAR(20),
    definition TEXT,
    chinese_meaning TEXT,
    legal_explanation TEXT,
    field VARCHAR(100),
    deck_id VARCHAR(36),
    srs_data JSON,
    mastery_level INT DEFAULT 0,
    review_count INT DEFAULT 0,
    correct_count INT DEFAULT 0,
    wrong_count INT DEFAULT 0,
    last_review_date DATE,
    next_review_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    INDEX idx_deck (deck_id),
    INDEX idx_next_review (next_review_date),
    INDEX idx_mastery (mastery_level),
    FULLTEXT INDEX idx_term (term) WITH PARSER ngram
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vocabulary Examples Table
CREATE TABLE IF NOT EXISTS vocabulary_examples (
    id VARCHAR(36) PRIMARY KEY,
    vocabulary_id VARCHAR(36) NOT NULL,
    sentence TEXT NOT NULL,
    translation TEXT,
    source VARCHAR(200),
    case_id VARCHAR(36),
    paragraph_number INT,
    is_user_added BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vocabulary_id) REFERENCES vocabulary(id) ON DELETE CASCADE,
    INDEX idx_vocabulary (vocabulary_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vocabulary Tags Table
CREATE TABLE IF NOT EXISTS vocabulary_tags (
    id VARCHAR(36) PRIMARY KEY,
    vocabulary_id VARCHAR(36) NOT NULL,
    tag VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vocabulary_id) REFERENCES vocabulary(id) ON DELETE CASCADE,
    UNIQUE KEY uk_vocab_tag (vocabulary_id, tag),
    INDEX idx_tag (tag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Decks Table
CREATE TABLE IF NOT EXISTS decks (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    is_built_in BOOLEAN DEFAULT FALSE,
    card_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Study Sets Table
CREATE TABLE IF NOT EXISTS study_sets (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    cover_image VARCHAR(500),
    mind_map_id VARCHAR(36),
    summary_note_id VARCHAR(36),
    tags JSON,
    item_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    INDEX idx_created_by (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Study Set Items Table
CREATE TABLE IF NOT EXISTS study_set_items (
    id VARCHAR(36) PRIMARY KEY,
    study_set_id VARCHAR(36) NOT NULL,
    item_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(36) NOT NULL,
    title VARCHAR(200),
    item_order INT DEFAULT 0,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (study_set_id) REFERENCES study_sets(id) ON DELETE CASCADE,
    INDEX idx_study_set (study_set_id),
    INDEX idx_entity (entity_id, item_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Mind Maps Table
CREATE TABLE IF NOT EXISTS mind_maps (
    id VARCHAR(36) PRIMARY KEY,
    study_set_id VARCHAR(36),
    name VARCHAR(200),
    layout_type VARCHAR(50) DEFAULT 'tree',
    nodes JSON,
    edges JSON,
    viewport JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    FOREIGN KEY (study_set_id) REFERENCES study_sets(id) ON DELETE SET NULL,
    INDEX idx_study_set (study_set_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Notes Table
CREATE TABLE IF NOT EXISTS notes (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(500),
    content JSON,
    parent_id VARCHAR(36),
    case_id VARCHAR(36),
    study_set_id VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    FOREIGN KEY (case_id) REFERENCES cases(id) ON DELETE SET NULL,
    FOREIGN KEY (study_set_id) REFERENCES study_sets(id) ON DELETE SET NULL,
    INDEX idx_case (case_id),
    INDEX idx_study_set (study_set_id),
    FULLTEXT INDEX idx_content (title) WITH PARSER ngram
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Relationships Table
CREATE TABLE IF NOT EXISTS relationships (
    id VARCHAR(36) PRIMARY KEY,
    source_id VARCHAR(36) NOT NULL,
    source_type VARCHAR(50) NOT NULL,
    target_id VARCHAR(36) NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    relation_type VARCHAR(50) NOT NULL DEFAULT 'related',
    description TEXT,
    is_bidirectional BOOLEAN DEFAULT TRUE,
    pair_id VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    UNIQUE KEY uk_relationship (source_id, target_id, relation_type),
    INDEX idx_source (source_id, source_type),
    INDEX idx_target (target_id, target_type),
    INDEX idx_type (relation_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- AI Queries Table
CREATE TABLE IF NOT EXISTS ai_queries (
    id VARCHAR(36) PRIMARY KEY,
    query TEXT NOT NULL,
    response TEXT,
    context JSON,
    model VARCHAR(100),
    tokens_used INT,
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36),
    INDEX idx_created_by (created_by),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
