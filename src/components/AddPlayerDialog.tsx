import { useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { UserPlus } from "lucide-react";
import { POSITIONS } from "@/types/basketball";
import { supabase } from "@/integrations/supabase/client";
import { useToast } from "@/hooks/use-toast";

interface AddPlayerDialogProps {
  onPlayerAdded: () => void;
}

export const AddPlayerDialog = ({ onPlayerAdded }: AddPlayerDialogProps) => {
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    age: "",
    position: "",
    jersey_number: ""
  });
  const { toast } = useToast();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim()) {
      toast({
        title: "Ошибка",
        description: "Имя игрока обязательно для заполнения",
        variant: "destructive"
      });
      return;
    }

    setLoading(true);
    try {
      const { error } = await supabase
        .from('players')
        .insert([{
          name: formData.name.trim(),
          age: formData.age ? parseInt(formData.age) : null,
          position: formData.position || null,
          jersey_number: formData.jersey_number ? parseInt(formData.jersey_number) : null
        }]);

      if (error) throw error;

      toast({
        title: "Успех!",
        description: `Игрок ${formData.name} добавлен в команду`,
        className: "bg-success text-success-foreground"
      });

      setFormData({ name: "", age: "", position: "", jersey_number: "" });
      setOpen(false);
      onPlayerAdded();
    } catch (error) {
      console.error('Error adding player:', error);
      toast({
        title: "Ошибка",
        description: "Не удалось добавить игрока",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button className="bg-gradient-primary hover:shadow-glow transition-all duration-300">
          <UserPlus className="h-4 w-4 mr-2" />
          Добавить игрока
        </Button>
      </DialogTrigger>
      <DialogContent className="bg-card/95 backdrop-blur-sm border-border/50">
        <DialogHeader>
          <DialogTitle className="text-xl font-bold">Добавить нового игрока</DialogTitle>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="name">Имя игрока *</Label>
            <Input
              id="name"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="Введите имя игрока"
              className="bg-background/50"
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="age">Возраст</Label>
              <Input
                id="age"
                type="number"
                value={formData.age}
                onChange={(e) => setFormData({ ...formData, age: e.target.value })}
                placeholder="Возраст"
                className="bg-background/50"
                min="5"
                max="25"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="jersey">Номер</Label>
              <Input
                id="jersey"
                type="number"
                value={formData.jersey_number}
                onChange={(e) => setFormData({ ...formData, jersey_number: e.target.value })}
                placeholder="№"
                className="bg-background/50"
                min="1"
                max="99"
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="position">Позиция</Label>
            <Select value={formData.position} onValueChange={(value) => setFormData({ ...formData, position: value })}>
              <SelectTrigger className="bg-background/50">
                <SelectValue placeholder="Выберите позицию" />
              </SelectTrigger>
              <SelectContent>
                {POSITIONS.map((position) => (
                  <SelectItem key={position} value={position}>
                    {position}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="flex gap-3 pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={() => setOpen(false)}
              className="flex-1"
              disabled={loading}
            >
              Отмена
            </Button>
            <Button 
              type="submit" 
              className="flex-1 bg-gradient-primary hover:shadow-glow"
              disabled={loading}
            >
              {loading ? "Добавление..." : "Добавить игрока"}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
};