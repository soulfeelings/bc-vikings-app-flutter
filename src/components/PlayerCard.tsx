import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Trophy, Target, Calendar, TrendingUp } from "lucide-react";
import { Player, LEVEL_NAMES, LEVEL_COLORS } from "@/types/basketball";

interface PlayerCardProps {
  player: Player;
  onMarkAttendance?: (playerId: string) => void;
  showAttendanceButton?: boolean;
}

export const PlayerCard = ({ player, onMarkAttendance, showAttendanceButton = false }: PlayerCardProps) => {
  const getInitials = (name: string) => {
    return name.split(' ').map(n => n[0]).join('').toUpperCase();
  };

  const getLevelProgress = (level: number, points: number) => {
    const thresholds = [0, 50, 150, 300, 500];
    const current = thresholds[level - 1] || 0;
    const next = thresholds[level] || 500;
    return ((points - current) / (next - current)) * 100;
  };

  return (
    <Card className="bg-card/80 backdrop-blur-sm border-border/50 hover:shadow-primary/20 hover:shadow-lg transition-all duration-300 animate-bounce-in group">
      <CardHeader className="pb-3">
        <div className="flex items-start justify-between">
          <div className="flex items-center space-x-3">
            <Avatar className="h-12 w-12 ring-2 ring-primary/20">
              <AvatarImage src={player.avatar_url} alt={player.name} />
              <AvatarFallback className="bg-gradient-primary text-primary-foreground font-bold">
                {getInitials(player.name)}
              </AvatarFallback>
            </Avatar>
            <div>
              <h3 className="font-bold text-lg leading-none">{player.name}</h3>
              {player.position && (
                <p className="text-sm text-muted-foreground mt-1">{player.position}</p>
              )}
              {player.jersey_number && (
                <Badge variant="outline" className="mt-1 text-xs">
                  #{player.jersey_number}
                </Badge>
              )}
            </div>
          </div>
          <div className="text-right">
            <div className={`text-sm font-semibold ${LEVEL_COLORS[player.level as keyof typeof LEVEL_COLORS]}`}>
              {LEVEL_NAMES[player.level as keyof typeof LEVEL_NAMES]}
            </div>
            <div className="text-xs text-muted-foreground">Уровень {player.level}</div>
          </div>
        </div>
      </CardHeader>
      
      <CardContent className="space-y-4">
        {/* Stats Grid */}
        <div className="grid grid-cols-3 gap-4">
          <div className="text-center">
            <div className="flex items-center justify-center mb-1">
              <Trophy className="h-4 w-4 text-accent mr-1" />
            </div>
            <div className="text-lg font-bold text-primary">{player.total_points}</div>
            <div className="text-xs text-muted-foreground">Очки</div>
          </div>
          
          <div className="text-center">
            <div className="flex items-center justify-center mb-1">
              <Calendar className="h-4 w-4 text-success mr-1" />
            </div>
            <div className="text-lg font-bold text-success">{player.attendance_count}</div>
            <div className="text-xs text-muted-foreground">Посещений</div>
          </div>
          
          <div className="text-center">
            <div className="flex items-center justify-center mb-1">
              <TrendingUp className="h-4 w-4 text-primary-glow mr-1" />
            </div>
            <div className="text-lg font-bold text-primary-glow">{player.level}</div>
            <div className="text-xs text-muted-foreground">Уровень</div>
          </div>
        </div>

        {/* Level Progress Bar */}
        <div className="space-y-2">
          <div className="flex justify-between text-xs">
            <span className="text-muted-foreground">Прогресс уровня</span>
            <span className="text-primary">{Math.round(getLevelProgress(player.level, player.total_points))}%</span>
          </div>
          <div className="w-full bg-muted rounded-full h-2">
            <div 
              className="bg-gradient-primary h-2 rounded-full transition-all duration-500"
              style={{ width: `${Math.min(100, getLevelProgress(player.level, player.total_points))}%` }}
            />
          </div>
        </div>

        {/* Action Button */}
        {showAttendanceButton && onMarkAttendance && (
          <Button 
            onClick={() => onMarkAttendance(player.id)}
            className="w-full bg-gradient-primary hover:shadow-glow transition-all duration-300"
            size="sm"
          >
            <Target className="h-4 w-4 mr-2" />
            Отметить посещение
          </Button>
        )}
      </CardContent>
    </Card>
  );
};