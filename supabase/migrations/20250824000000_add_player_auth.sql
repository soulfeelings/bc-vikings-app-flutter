-- Add login and password fields to players table
ALTER TABLE public.players 
ADD COLUMN login TEXT UNIQUE,
ADD COLUMN password TEXT;

-- Remove jersey_number field as it's no longer needed
ALTER TABLE public.players 
DROP COLUMN jersey_number;

-- Update existing players with default login (can be changed later)
UPDATE public.players 
SET login = LOWER(REPLACE(name, ' ', '_')) || '_' || SUBSTRING(id::text, 1, 4)
WHERE login IS NULL;

-- Make login required for new players
ALTER TABLE public.players 
ALTER COLUMN login SET NOT NULL;
