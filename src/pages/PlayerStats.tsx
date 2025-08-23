import { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Progress } from "@/components/ui/progress";
import {
  ArrowLeft,
  Trophy,
  Calendar,
  Target,
  TrendingUp,
  Award,
  Clock,
} from "lucide-react";
import { Player, Attendance, TrainingSession } from "@/types/basketball";
import { LEVEL_NAMES, LEVEL_COLORS } from "@/types/basketball";
import { supabase } from "@/integrations/supabase/client";
import { useToast } from "@/hooks/use-toast";

interface AttendanceWithSession extends Attendance {
  training_sessions: TrainingSession;
}

interface PlayerStatsProps {
  playerId?: string;
  showBackButton?: boolean;
  onBack?: () => void;
}

export const PlayerStats = ({
  playerId,
  showBackButton = true,
  onBack,
}: PlayerStatsProps) => {
  const { id } = useParams<{ id: string }>();
  const actualPlayerId = playerId || id;
  const [player, setPlayer] = useState<Player | null>(null);
  const [attendanceHistory, setAttendanceHistory] = useState<
    AttendanceWithSession[]
  >([]);
  const [loading, setLoading] = useState(true);
  const { toast } = useToast();

  useEffect(() => {
    if (actualPlayerId) {
      loadPlayerData(actualPlayerId);
    }
  }, [actualPlayerId]);

  const loadPlayerData = async (playerId: string) => {
    try {
      console.log("Loading player data for ID:", playerId);
      // Load player data
      const { data: playerData, error: playerError } = await supabase
        .from("players")
        .select("*")
        .eq("id", playerId)
        .single();

      if (playerError) throw playerError;
      console.log("Player data loaded:", playerData);

      // Load attendance history with session details
      const { data: attendanceData, error: attendanceError } = await supabase
        .from("attendance")
        .select(
          `
          *,
          training_sessions (*)
        `
        )
        .eq("player_id", playerId)
        .order("created_at", { ascending: false })
        .limit(20);

      if (attendanceError) throw attendanceError;
      console.log("Attendance data loaded:", attendanceData);

      setPlayer(playerData);
      setAttendanceHistory(attendanceData || []);
    } catch (error) {
      console.error("Error loading player data:", error);
      toast({
        title: "Ошибка",
        description: "Не удалось загрузить данные игрока",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const getNextLevelPoints = (currentLevel: number, currentPoints: number) => {
    const levelThresholds = [0, 50, 150, 300, 500];
    const nextThreshold = levelThresholds[currentLevel] || 500;
    return Math.max(0, nextThreshold - currentPoints);
  };

  const getLevelProgress = (currentLevel: number, currentPoints: number) => {
    const levelThresholds = [0, 50, 150, 300, 500];
    const currentThreshold = levelThresholds[currentLevel - 1] || 0;
    const nextThreshold = levelThresholds[currentLevel] || 500;
    const progress =
      ((currentPoints - currentThreshold) /
        (nextThreshold - currentThreshold)) *
      100;
    return Math.min(100, Math.max(0, progress));
  };

  const getAttendanceRate = () => {
    if (attendanceHistory.length === 0) return 0;
    const attendedSessions = attendanceHistory.filter((a) => a.attended).length;
    return Math.round((attendedSessions / attendanceHistory.length) * 100);
  };

  const getRecentPerformance = () => {
    const recent = attendanceHistory.slice(0, 5);
    return recent.map((a) => a.attended);
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Загрузка...</p>
        </div>
      </div>
    );
  }

  if (!player) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold mb-4">Игрок не найден</h1>
          <Link to="/">
            <Button>
              <ArrowLeft className="h-4 w-4 mr-2" />
              Вернуться на главную
            </Button>
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen p-6 space-y-8">
      {/* Header */}
      <div className="flex items-center gap-4">
        {showBackButton &&
          (onBack ? (
            <Button variant="outline" size="sm" onClick={onBack}>
              <ArrowLeft className="h-4 w-4 mr-2" />
              Назад
            </Button>
          ) : (
            <Link to="/">
              <Button variant="outline" size="sm">
                <ArrowLeft className="h-4 w-4 mr-2" />
                Назад
              </Button>
            </Link>
          ))}
        <h1 className="text-3xl font-bold bg-gradient-primary bg-clip-text text-transparent">
          Статистика игрока
        </h1>
      </div>

      {/* Player Profile Card */}
      <Card className="bg-card/80 backdrop-blur-sm border-border/50">
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row items-center gap-6">
            <Avatar className="h-24 w-24">
              <AvatarImage src={player.avatar_url} alt={player.name} />
              <AvatarFallback className="text-2xl bg-gradient-primary text-white">
                {player.name
                  .split(" ")
                  .map((n) => n[0])
                  .join("")}
              </AvatarFallback>
            </Avatar>

            <div className="flex-1 text-center md:text-left space-y-2">
              <h2 className="text-2xl font-bold">{player.name}</h2>
              <div className="flex flex-wrap gap-2 justify-center md:justify-start">
                {player.position && (
                  <Badge variant="secondary">{player.position}</Badge>
                )}
                <Badge variant="outline">@{player.login}</Badge>
                {player.age && (
                  <Badge variant="outline">{player.age} лет</Badge>
                )}
              </div>

              <div className="flex items-center gap-2 justify-center md:justify-start">
                <Award className="h-5 w-5 text-accent" />
                <span
                  className={`font-bold ${
                    LEVEL_COLORS[player.level as keyof typeof LEVEL_COLORS]
                  }`}
                >
                  {LEVEL_NAMES[player.level as keyof typeof LEVEL_NAMES]}{" "}
                  (Уровень {player.level})
                </span>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="bg-card/80 backdrop-blur-sm border-border/50 hover:shadow-primary/20 hover:shadow-lg transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Общие очки</CardTitle>
            <Trophy className="h-4 w-4 text-accent" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-accent">
              {player.total_points}
            </div>
            <p className="text-xs text-muted-foreground">
              До следующего уровня:{" "}
              {getNextLevelPoints(player.level, player.total_points)} очков
            </p>
          </CardContent>
        </Card>

        <Card className="bg-card/80 backdrop-blur-sm border-border/50 hover:shadow-primary/20 hover:shadow-lg transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Посещено тренировок
            </CardTitle>
            <Calendar className="h-4 w-4 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-primary">
              {player.attendance_count}
            </div>
            <p className="text-xs text-muted-foreground">
              Процент посещаемости: {getAttendanceRate()}%
            </p>
          </CardContent>
        </Card>

        <Card className="bg-card/80 backdrop-blur-sm border-border/50 hover:shadow-primary/20 hover:shadow-lg transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Текущий уровень
            </CardTitle>
            <Target className="h-4 w-4 text-primary-glow" />
          </CardHeader>
          <CardContent>
            <div
              className={`text-2xl font-bold ${
                LEVEL_COLORS[player.level as keyof typeof LEVEL_COLORS]
              }`}
            >
              {player.level}
            </div>
            <div className="mt-2">
              <Progress
                value={getLevelProgress(player.level, player.total_points)}
                className="h-2"
              />
            </div>
          </CardContent>
        </Card>

        <Card className="bg-card/80 backdrop-blur-sm border-border/50 hover:shadow-primary/20 hover:shadow-lg transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Последние тренировки
            </CardTitle>
            <TrendingUp className="h-4 w-4 text-success" />
          </CardHeader>
          <CardContent>
            <div className="flex gap-1">
              {getRecentPerformance().map((attended, index) => (
                <div
                  key={index}
                  className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold ${
                    attended
                      ? "bg-success text-success-foreground"
                      : "bg-destructive text-destructive-foreground"
                  }`}
                >
                  {attended ? "✓" : "✗"}
                </div>
              ))}
            </div>
            <p className="text-xs text-muted-foreground mt-2">
              Последние 5 тренировок
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Attendance History */}
      <Card className="bg-card/80 backdrop-blur-sm border-border/50">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Clock className="h-5 w-5" />
            История посещений
          </CardTitle>
        </CardHeader>
        <CardContent>
          {attendanceHistory.length === 0 ? (
            <p className="text-muted-foreground text-center py-8">
              Нет данных о посещениях
            </p>
          ) : (
            <div className="space-y-3">
              {attendanceHistory.map((attendance) => (
                <div
                  key={attendance.id}
                  className="flex items-center justify-between p-3 rounded-lg bg-background/50"
                >
                  <div className="flex items-center gap-3">
                    <div
                      className={`w-3 h-3 rounded-full ${
                        attendance.attended ? "bg-success" : "bg-destructive"
                      }`}
                    />
                    <div>
                      <p className="font-medium">
                        {attendance.training_sessions.title}
                      </p>
                      <p className="text-sm text-muted-foreground">
                        {new Date(
                          attendance.training_sessions.date
                        ).toLocaleDateString("ru-RU")}
                      </p>
                    </div>
                  </div>

                  <div className="text-right">
                    <p
                      className={`font-bold ${
                        attendance.attended
                          ? "text-success"
                          : "text-destructive"
                      }`}
                    >
                      {attendance.attended ? "Присутствовал" : "Отсутствовал"}
                    </p>
                    {attendance.attended && (
                      <p className="text-sm text-muted-foreground">
                        +{attendance.points_earned} очков
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};
