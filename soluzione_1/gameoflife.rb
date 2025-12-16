require 'matrix'
require 'io/console'


$generazione =0
$matrix = []
$name_file = ""

def plot_matrix(matrice)
    puts " "
    puts "Generation #{$generazione}:"
    puts "#{matrice.row_count} #{matrice.column_count}"

    matrice.each_with_index do |valore, r, c|
        
        simbolo = case valore
                when 0
                    "."  
                when 1
                    "*"  
                else
                    valore
                end
                
        
        print simbolo
        
        if c == matrice.column_count - 1
            print "\n" 
        else
            print " " 
        end
    end
    
end

def next_generation(world)
    $generazione +=1
    next_generation_world= world.clone
    
    world.each_with_index do |valore, idx_r, idx_c|

        if idx_r -1 <0 
            r_i = idx_r
            n_r = 2
        elsif idx_r+1 > world.row_count
            r_i = idx_r -1
            n_r = 2
        else
            r_i = idx_r -1
            n_r = 3
        end

        if idx_c -1 <0 
            c_i = idx_c
            n_c = 2
        elsif idx_c+1 > world.column_count
            c_i = idx_c -1
            n_c = 2
        else
            c_i = idx_c -1
            n_c = 3
        end


        mat = world.minor(r_i, n_r, c_i, n_c )
        celle_vive = mat.sum - valore


        # puts " Celle Vive intorno a (#{idx_r},#{idx_c}): #{celle_vive}"

        if valore == 1 && (celle_vive <2 || celle_vive >3)
            next_generation_world[idx_r,idx_c] = 0
        elsif valore == 1 && (celle_vive == 2 || celle_vive ==3)
            next_generation_world[idx_r,idx_c] = 1
        elsif valore==0 && celle_vive == 3
            next_generation_world[idx_r, idx_c] = 1
        end


    end

    plot_matrix(next_generation_world)

    return next_generation_world
end

$name_file = ARGV[0] if ARGV.length > 0
if $name_file == ""
    puts "Errore: Nessun file di input specificato.\n- ruby gameoflife.rb <nome_file>"
    exit 1
elsif not File.exist?($name_file)
    puts "Errore: Il file '#{$name_file}' non esiste."
    exit 1
elsif File.zero?($name_file)
    puts "Errore: Il file '#{$name_file}' è vuoto (0 byte)."
    exit 1
end

begin
    File.open($name_file).readlines.each_with_index do |line, idx|

        case idx
            when 0
                if line.match(/^Generation \d:/)
                    $generazione = line.gsub(":","").split(' ')[1].to_i
                else
                    raise ArgumentError, "Formato non atteso alla posizione #{idx+1}. Verificare che i dati nel file '#{$name_file}' rispettino la struttura prevista e riprovare."
                end
            when 1
                $rows, $cols = line.split(' ').map(&:to_i)
                if not (Integer($rows) || Integer($cols))
                    raise ArgumentError, "Formato non atteso alla posizione #{idx+1}. Verificare che i dati nel file '#{$name_file}' rispettino la struttura prevista e riprovare."
                end

                puts "Generazione: #{$generazione}, Righe: #{$rows}, Colonne: #{$cols}"
            
            else
                r = line.strip.gsub(".", "0").gsub("*","1").chars
                if r.length == $cols
                    $matrix=Matrix.rows($matrix.to_a << r.map(&:to_i))
                else
                    raise ArgumentError, "Formato non atteso alla posizione #{idx+1}. Verificare che i dati nel file '#{$name_file}' rispettino la struttura prevista e riprovare."
                end
            end

    end

    if $matrix.row_count != $rows
        raise ArgumentError, "Numero di righe nel file non corrisponde al valore specificato."
    end

    plot_matrix($matrix)

rescue Errno::ENOENT => e
  puts "Errore File: #{e.message}"
  exit 1
rescue => e
  puts "Errore: #{e.message}"
  exit 1
end

$matrix = next_generation($matrix)
puts "Premere 'n' per avanzare alla prossima generazione, 'Esc' o 'Ctrl+X' per uscire."

loop do
    char = $stdin.getch
    case char
        when "\e"  # Esc
            break
        when "\u0018"  # Ctrl+X
            break
        when "n"
            $matrix = next_generation($matrix)
            puts "\nPremere 'n' per avanzare alla prossima generazione, 'Esc' o 'Ctrl+X' per uscire."
        else
            puts "Tasto non riconosciuto (codice: #{char.ord}). Premere 'n' o per avanzare, 'Esc' o 'Ctrl+X' per uscire."
        end
end