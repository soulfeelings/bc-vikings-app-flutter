import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Users, LogIn, AlertCircle } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface CoachLoginProps {
  onCoachLogin: () => void;
  onBackToModeSelect: () => void;
}

export const CoachLogin = ({
  onCoachLogin,
  onBackToModeSelect,
}: CoachLoginProps) => {
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const { toast } = useToast();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!password.trim()) {
      setError("Введите пароль");
      return;
    }

    setLoading(true);
    setError("");

    // Простая проверка пароля
    if (password.trim() === "1") {
      toast({
        title: "Добро пожаловать!",
        description: "Вход в панель тренера выполнен",
        className: "bg-success text-success-foreground",
      });
      onCoachLogin();
    } else {
      setError("Неверный пароль");
    }

    setLoading(false);
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-6">
      <div className="text-center mb-8">
        <h1 className="text-4xl font-bold bg-gradient-primary bg-clip-text text-transparent mb-4">
          BC Vikings App
        </h1>
        <p className="text-muted-foreground text-lg">
          Система управления баскетбольной командой
        </p>
      </div>

      <Card className="w-full max-w-md bg-card/80 backdrop-blur-sm border-border/50">
        <CardHeader className="text-center">
          <div className="flex justify-center mb-4">
            <div className="p-3 bg-gradient-primary rounded-full">
              <Users className="h-8 w-8 text-white" />
            </div>
          </div>
          <CardTitle className="text-2xl bg-gradient-primary bg-clip-text text-transparent">
            Вход для тренера
          </CardTitle>
          <p className="text-muted-foreground">Введите пароль для входа</p>
        </CardHeader>

        <CardContent>
          <form onSubmit={handleLogin} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="password">Пароль</Label>
              <Input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Введите пароль"
                disabled={loading}
                className="w-full"
                autoFocus
              />
            </div>

            {error && (
              <Alert variant="destructive">
                <AlertCircle className="h-4 w-4" />
                <AlertDescription>{error}</AlertDescription>
              </Alert>
            )}

            <div className="space-y-3">
              <Button
                type="submit"
                disabled={loading}
                className="w-full bg-gradient-primary hover:shadow-glow transition-all duration-300"
              >
                {loading ? (
                  <div className="flex items-center gap-2">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white" />
                    Вход...
                  </div>
                ) : (
                  <>
                    <LogIn className="h-4 w-4 mr-2" />
                    Войти
                  </>
                )}
              </Button>

              <Button
                type="button"
                variant="outline"
                onClick={onBackToModeSelect}
                disabled={loading}
                className="w-full"
              >
                Назад к входу игрока
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
};
