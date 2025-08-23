import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Checkbox } from "@/components/ui/checkbox";
import { Trophy, Users, Calendar, TrendingUp, Target } from "lucide-react";
import { PlayerCard } from "@/components/PlayerCard";
import { AddPlayerDialog } from "@/components/AddPlayerDialog";
import { Player, TrainingSession } from "@/types/basketball";
import { supabase } from "@/integrations/supabase/client";
import { useToast } from "@/hooks/use-toast";

export const CoachDashboard = () => {
  const [players, setPlayers] = useState<Player[]>([]);
  const [sessions, setSessions] = useState<TrainingSession[]>([]);
  const [loading, setLoading] = useState(true);
  const [attendanceDialogOpen, setAttendanceDialogOpen] = useState(false);
  const [selectedSession, setSelectedSession] = useState<string | null>(null);
  const [attendanceMarks, setAttendanceMarks] = useState<
    Record<string, boolean>
  >({});
  const { toast } = useToast();

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      // Load players
      const { data: playersData, error: playersError } = await supabase
        .from("players")
        .select("*")
        .order("total_points", { ascending: false });

      if (playersError) throw playersError;

      // Load recent training sessions
      const { data: sessionsData, error: sessionsError } = await supabase
        .from("training_sessions")
        .select("*")
        .order("date", { ascending: false })
        .limit(5);

      if (sessionsError) throw sessionsError;

      setPlayers(playersData || []);
      setSessions(sessionsData || []);
    } catch (error) {
      console.error("Error loading data:", error);
      toast({
        title: "Ошибка",
        description: "Не удалось загрузить данные",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const createTodaySession = async () => {
    try {
      const today = new Date().toISOString().split("T")[0];

      // Check if session already exists for today
      const { data: existingSession } = await supabase
        .from("training_sessions")
        .select("*")
        .eq("date", today)
        .single();

      if (existingSession) {
        setSelectedSession(existingSession.id);
        initializeAttendanceMarks();
        setAttendanceDialogOpen(true);
        return;
      }

      // Create new session
      const { data: newSession, error } = await supabase
        .from("training_sessions")
        .insert([
          {
            date: today,
            title: `Тренировка ${new Date().toLocaleDateString("ru-RU")}`,
          },
        ])
        .select()
        .single();

      if (error) throw error;

      setSelectedSession(newSession.id);
      setSessions((prev) => [newSession, ...prev.slice(0, 4)]);
      initializeAttendanceMarks();
      setAttendanceDialogOpen(true);
    } catch (error) {
      console.error("Error creating session:", error);
      toast({
        title: "Ошибка",
        description: "Не удалось создать тренировку",
        variant: "destructive",
      });
    }
  };

  const initializeAttendanceMarks = () => {
    const marks: Record<string, boolean> = {};
    players.forEach((player) => {
      marks[player.id] = true; // Default to attended
    });
    setAttendanceMarks(marks);
  };

  const saveAttendance = async () => {
    if (!selectedSession) return;

    try {
      const attendanceRecords = Object.entries(attendanceMarks).map(
        ([playerId, attended]) => ({
          player_id: playerId,
          session_id: selectedSession,
          attended,
          points_earned: attended ? 10 : 0,
        })
      );

      const { error } = await supabase
        .from("attendance")
        .upsert(attendanceRecords, {
          onConflict: "player_id,session_id",
        });

      if (error) throw error;

      toast({
        title: "Успех!",
        description: "Посещаемость сохранена",
        className: "bg-success text-success-foreground",
      });

      setAttendanceDialogOpen(false);
      loadData(); // Reload to update player stats
    } catch (error) {
      console.error("Error saving attendance:", error);
      toast({
        title: "Ошибка",
        description: "Не удалось сохранить посещаемость",
        variant: "destructive",
      });
    }
  };

  const stats = {
    totalPlayers: players.length,
    totalPoints: players.reduce((sum, player) => sum + player.total_points, 0),
    averageAttendance:
      players.length > 0
        ? Math.round(
            players.reduce((sum, player) => sum + player.attendance_count, 0) /
              players.length
          )
        : 0,
    topPlayer: players[0],
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

  return (
    <div className="min-h-screen p-6 space-y-8">
      {/* Header */}
      <div className="text-center space-y-4">
        <h1 className="text-4xl font-bold bg-gradient-primary bg-clip-text text-transparent">
          Панель тренера
        </h1>
        <p className="text-muted-foreground text-lg">
          Управляйте своей командой и мотивируйте игроков
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="bg-card/80 backdrop-blur-sm border-border/50 hover:shadow-primary/20 hover:shadow-lg transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Всего игроков</CardTitle>
            <Users className="h-4 w-4 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-primary">
              {stats.totalPlayers}
            </div>
          </CardContent>
        </Card>

        <Card className="bg-card/80 backdrop-blur-sm border-border/50 hover:shadow-primary/20 hover:shadow-lg transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Общие очки</CardTitle>
            <Trophy className="h-4 w-4 text-accent" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-accent">
              {stats.totalPoints}
            </div>
          </CardContent>
        </Card>

        <Card className="bg-card/80 backdrop-blur-sm border-border/50 hover:shadow-primary/20 hover:shadow-lg transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Средняя посещаемость
            </CardTitle>
            <Calendar className="h-4 w-4 text-success" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-success">
              {stats.averageAttendance}
            </div>
          </CardContent>
        </Card>

        <Card className="bg-card/80 backdrop-blur-sm border-border/50 hover:shadow-primary/20 hover:shadow-lg transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Лидер команды</CardTitle>
            <TrendingUp className="h-4 w-4 text-primary-glow" />
          </CardHeader>
          <CardContent>
            <div className="text-sm font-bold text-primary-glow">
              {stats.topPlayer?.name || "Нет игроков"}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Action Buttons */}
      <div className="flex flex-wrap gap-4 justify-center">
        <AddPlayerDialog onPlayerAdded={loadData} />
        <Button
          onClick={createTodaySession}
          className="bg-gradient-gold hover:shadow-glow transition-all duration-300"
        >
          <Target className="h-4 w-4 mr-2" />
          Отметить посещаемость
        </Button>
      </div>

      {/* Players Grid */}
      <div className="space-y-6">
        <h2 className="text-2xl font-bold text-center">Команда</h2>
        {players.length === 0 ? (
          <Card className="bg-card/80 backdrop-blur-sm border-border/50 p-8 text-center">
            <div className="space-y-4">
              <Users className="h-12 w-12 mx-auto text-muted-foreground" />
              <div>
                <h3 className="text-lg font-semibold mb-2">Команда пуста</h3>
                <p className="text-muted-foreground mb-4">
                  Добавьте первого игрока, чтобы начать работу с командой
                </p>
                <AddPlayerDialog onPlayerAdded={loadData} />
              </div>
            </div>
          </Card>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {players.map((player) => (
              <PlayerCard key={player.id} player={player} />
            ))}
          </div>
        )}
      </div>

      {/* Attendance Dialog */}
      <Dialog
        open={attendanceDialogOpen}
        onOpenChange={setAttendanceDialogOpen}
      >
        <DialogContent className="bg-card/95 backdrop-blur-sm border-border/50 max-w-md">
          <DialogHeader>
            <DialogTitle className="text-xl font-bold">
              Отметить посещаемость
            </DialogTitle>
          </DialogHeader>

          <div className="space-y-4 max-h-96 overflow-y-auto">
            {players.map((player) => (
              <div
                key={player.id}
                className="flex items-center space-x-3 p-3 rounded-lg bg-background/50"
              >
                <Checkbox
                  id={player.id}
                  checked={attendanceMarks[player.id] || false}
                  onCheckedChange={(checked) =>
                    setAttendanceMarks((prev) => ({
                      ...prev,
                      [player.id]: checked as boolean,
                    }))
                  }
                />
                <label
                  htmlFor={player.id}
                  className="flex-1 font-medium cursor-pointer"
                >
                  {player.name}
                  <span className="text-sm text-muted-foreground ml-2">
                    @{player.login}
                  </span>
                </label>
              </div>
            ))}
          </div>

          <div className="flex gap-3 pt-4">
            <Button
              variant="outline"
              onClick={() => setAttendanceDialogOpen(false)}
              className="flex-1"
            >
              Отмена
            </Button>
            <Button
              onClick={saveAttendance}
              className="flex-1 bg-gradient-primary hover:shadow-glow"
            >
              Сохранить
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
};
