-- Create players table
CREATE TABLE public.players (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  age INTEGER,
  position TEXT,
  jersey_number INTEGER,
  total_points INTEGER DEFAULT 0,
  attendance_count INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create training sessions table
CREATE TABLE public.training_sessions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL,
  title TEXT NOT NULL DEFAULT 'Тренировка',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create attendance table
CREATE TABLE public.attendance (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES public.training_sessions(id) ON DELETE CASCADE,
  attended BOOLEAN DEFAULT true,
  points_earned INTEGER DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(player_id, session_id)
);

-- Enable Row Level Security
ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.training_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;

-- Create policies (для простоты делаем публичными, позже можно добавить авторизацию)
CREATE POLICY "Anyone can manage players" ON public.players FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Anyone can manage sessions" ON public.training_sessions FOR ALL USING (true) WITH CHECK (true);  
CREATE POLICY "Anyone can manage attendance" ON public.attendance FOR ALL USING (true) WITH CHECK (true);

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic timestamp updates
CREATE TRIGGER update_players_updated_at
  BEFORE UPDATE ON public.players
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Create function to update player stats when attendance is added
CREATE OR REPLACE FUNCTION public.update_player_stats()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.attended THEN
    UPDATE public.players
    SET 
      total_points = total_points + COALESCE(NEW.points_earned, 10),
      attendance_count = attendance_count + 1,
      level = CASE 
        WHEN total_points + COALESCE(NEW.points_earned, 10) >= 500 THEN 5
        WHEN total_points + COALESCE(NEW.points_earned, 10) >= 300 THEN 4
        WHEN total_points + COALESCE(NEW.points_earned, 10) >= 150 THEN 3
        WHEN total_points + COALESCE(NEW.points_earned, 10) >= 50 THEN 2
        ELSE 1
      END
    WHERE id = NEW.player_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updating player stats
CREATE TRIGGER update_player_stats_trigger
  AFTER INSERT OR UPDATE ON public.attendance
  FOR EACH ROW
  EXECUTE FUNCTION public.update_player_stats();