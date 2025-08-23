import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Calendar, Users, Target } from "lucide-react";
import { TrainingSession } from "@/types/basketball";

interface TrainingSessionCardProps {
  session: TrainingSession;
  playerCount: number;
  onMarkAttendance: (sessionId: string) => void;
}

export const TrainingSessionCard = ({ session, playerCount, onMarkAttendance }: TrainingSessionCardProps) => {
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('ru-RU', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  const isToday = (dateString: string) => {
    const today = new Date();
    const sessionDate = new Date(dateString);
    return today.toDateString() === sessionDate.toDateString();
  };

  return (
    <Card className={`bg-card/80 backdrop-blur-sm border-border/50 hover:shadow-primary/20 hover:shadow-lg transition-all duration-300 ${isToday(session.date) ? 'ring-2 ring-primary animate-glow' : ''}`}>
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg flex items-center gap-2">
            <Calendar className="h-5 w-5 text-primary" />
            {session.title}
            {isToday(session.date) && (
              <span className="text-xs bg-primary text-primary-foreground px-2 py-1 rounded-full">
                Сегодня
              </span>
            )}
          </CardTitle>
          <div className="flex items-center gap-1 text-sm text-muted-foreground">
            <Users className="h-4 w-4" />
            {playerCount}
          </div>
        </div>
      </CardHeader>
      
      <CardContent className="space-y-4">
        <div className="text-sm text-muted-foreground">
          {formatDate(session.date)}
        </div>
        
        <Button 
          onClick={() => onMarkAttendance(session.id)}
          className="w-full bg-gradient-primary hover:shadow-glow transition-all duration-300"
          size="sm"
        >
          <Target className="h-4 w-4 mr-2" />
          Отметить посещаемость
        </Button>
      </CardContent>
    </Card>
  );
};