export interface Player {
  id: string;
  name: string;
  age?: number;
  position?: string;
  login: string;
  password?: string;
  total_points: number;
  attendance_count: number;
  level: number;
  avatar_url?: string;
  created_at: string;
  updated_at: string;
}

export interface TrainingSession {
  id: string;
  date: string;
  title: string;
  created_at: string;
}

export interface Attendance {
  id: string;
  player_id: string;
  session_id: string;
  attended: boolean;
  points_earned: number;
  created_at: string;
}

export interface PlayerWithAttendance extends Player {
  recent_attendance?: Attendance[];
}

export const POSITIONS = [
  "Point Guard",
  "Shooting Guard",
  "Small Forward",
  "Power Forward",
  "Center",
] as const;

export const LEVEL_NAMES = {
  1: "Новичок",
  2: "Любитель",
  3: "Игрок",
  4: "Звезда",
  5: "Легенда",
} as const;

export const LEVEL_COLORS = {
  1: "text-muted-foreground",
  2: "text-accent",
  3: "text-primary",
  4: "text-primary-glow",
  5: "text-accent bg-gradient-primary bg-clip-text text-transparent",
} as const;
