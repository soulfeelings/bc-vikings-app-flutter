import { useState, useEffect } from "react";
import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { Button } from "@/components/ui/button";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { LogOut } from "lucide-react";
import { CoachDashboard } from "./pages/CoachDashboard";
import { PlayerStats } from "./pages/PlayerStats";
import { PlayerLogin } from "./pages/PlayerLogin";
import { CoachLogin } from "./pages/CoachLogin";
import { Player } from "./types/basketball";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

const App = () => {
  const [mode, setMode] = useState<"coach" | "player">("player");
  const [loggedInPlayer, setLoggedInPlayer] = useState<Player | null>(null);
  const [isCoachAuthenticated, setIsCoachAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  // Загрузка сессии из localStorage при старте приложения
  useEffect(() => {
    const savedSession = localStorage.getItem("bc-vikings-session");
    if (savedSession) {
      try {
        const session = JSON.parse(savedSession);
        if (session.type === "coach" && session.authenticated) {
          setMode("coach");
          setIsCoachAuthenticated(true);
        } else if (session.type === "player" && session.player) {
          setMode("player");
          setLoggedInPlayer(session.player);
        }
      } catch (error) {
        console.error("Error loading session:", error);
        localStorage.removeItem("bc-vikings-session");
      }
    }
    setLoading(false);
  }, []);

  const handleModeChange = (selectedMode: "coach" | "player") => {
    if (selectedMode === "player") {
      setMode("player");
      setIsCoachAuthenticated(false);
    } else {
      setMode("coach");
      setLoggedInPlayer(null);
    }
  };

  const handlePlayerLogin = (player: Player) => {
    setLoggedInPlayer(player);
    // Сохраняем сессию игрока в localStorage
    localStorage.setItem(
      "bc-vikings-session",
      JSON.stringify({
        type: "player",
        player: player,
      })
    );
  };

  const handleCoachLogin = () => {
    setIsCoachAuthenticated(true);
    // Сохраняем сессию тренера в localStorage
    localStorage.setItem(
      "bc-vikings-session",
      JSON.stringify({
        type: "coach",
        authenticated: true,
      })
    );
  };

  const handleBackToPlayerLogin = () => {
    setMode("player");
    setLoggedInPlayer(null);
    setIsCoachAuthenticated(false);
  };

  const handleSwitchToCoachMode = () => {
    setMode("coach");
    setLoggedInPlayer(null);
  };

  const handleLogout = () => {
    setMode("player");
    setLoggedInPlayer(null);
    setIsCoachAuthenticated(false);
    localStorage.removeItem("bc-vikings-session");
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
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <div className="min-h-screen bg-gradient-to-br from-background via-background to-background/80">
          {mode === "player" && !loggedInPlayer && (
            <PlayerLogin
              onPlayerLogin={handlePlayerLogin}
              onSwitchToCoachMode={handleSwitchToCoachMode}
            />
          )}

          {mode === "player" && loggedInPlayer && (
            <div>
              <div className="p-4 flex justify-end">
                <Button
                  variant="outline"
                  onClick={handleLogout}
                  className="flex items-center gap-2"
                >
                  <LogOut className="h-4 w-4" />
                  Выход
                </Button>
              </div>
              <PlayerStats
                playerId={loggedInPlayer.id}
                showBackButton={false}
              />
            </div>
          )}

          {mode === "coach" && !isCoachAuthenticated && (
            <CoachLogin
              onCoachLogin={handleCoachLogin}
              onBackToModeSelect={handleBackToPlayerLogin}
            />
          )}

          {mode === "coach" && isCoachAuthenticated && (
            <BrowserRouter>
              <div>
                <div className="p-4 flex justify-end">
                  <Button
                    variant="outline"
                    onClick={handleLogout}
                    className="flex items-center gap-2"
                  >
                    <LogOut className="h-4 w-4" />
                    Выход
                  </Button>
                </div>
                <Routes>
                  <Route path="/" element={<CoachDashboard />} />
                  <Route path="/player/:id" element={<PlayerStats />} />
                  <Route path="*" element={<NotFound />} />
                </Routes>
              </div>
            </BrowserRouter>
          )}
        </div>
      </TooltipProvider>
    </QueryClientProvider>
  );
};

export default App;
