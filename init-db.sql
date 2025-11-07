-- Initialize database with default data
-- This script runs when PostgreSQL container starts for the first time

-- Insert default users with hashed passwords
INSERT INTO users (name, role, email, password_hash, active) VALUES 
('Admin Park M', 'admin', 'admin@park-m.pl', '$2b$10$rQZ8ZpGsjjLxvUqJwJvJKeOjJd8JjJvJKeOjJd8JjJvJKeOjJd8Jj', true),
('Jan Kowalski', 'brygadzista', 'jan.kowalski@park-m.pl', '$2b$10$rQZ8ZpGsjjLxvUqJwJvJKeOjJd8JjJvJKeOjJd8JjJvJKeOjJd8Jj', true),
('Anna Nowak', 'pracownik', 'anna.nowak@park-m.pl', '$2b$10$rQZ8ZpGsjjLxvUqJwJvJKeOjJd8JjJvJKeOjJd8JjJvJKeOjJd8Jj', true),
('Piotr Wiśniewski', 'pracownik', 'piotr.wisniewski@park-m.pl', '$2b$10$rQZ8ZpGsjjLxvUqJwJvJKeOjJd8JjJvJKeOjJd8JjJvJKeOjJd8Jj', true)
ON CONFLICT (email) DO NOTHING;

-- Insert default sites
INSERT INTO sites (code, name, address, active) VALUES 
('BUD-001', 'Park Centralny', 'ul. Parkowa 1, Warszawa', true),
('BUD-002', 'Osiedle Zielone', 'ul. Kwiatowa 15, Kraków', true),
('BUD-003', 'Skwer Miejski', 'ul. Główna 50, Wrocław', true)
ON CONFLICT (code) DO NOTHING;

-- Insert default species
INSERT INTO species (name, scientific_name, active) VALUES 
('Dąb szypułkowy', 'Quercus robur', true),
('Klon zwyczajny', 'Acer platanoides', true),
('Lipa drobnolistna', 'Tilia cordata', true),
('Brzoza brodawkowata', 'Betula pendula', true),
('Sosna zwyczajna', 'Pinus sylvestris', true),
('Świerk pospolity', 'Picea abies', true),
('Lipa srebrzysta Brabant', 'Tilia tomentosa Brabant', true),
('Wiśnia piłkowana Kanzan', 'Prunus serrulata Kanzan', true),
('Grusza drobnoowocowa Chanticleer', 'Pyrus calleryana Chanticleer', true)
ON CONFLICT (name) DO NOTHING;
