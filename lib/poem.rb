class Poem < ActiveRecord::Base

    @@prompt = TTY::Prompt.new
    
    belongs_to :author
    has_many :lessons
    has_many :users, through: :lessons


    def self.search_for_poem
        CommandLineInterface.logo("./design/logo_small.png", false)
        @@poem_selection = @@prompt.select("Search by:") do |menu|
            menu.choice "* Title", -> {search_by_title}
            menu.choice "* Author", -> {Author.search_by_author}
            menu.choice "* Back to Main Menu", -> {
                CommandLineInterface.logo("./design/logo_small.png", false);
                CommandLineInterface.general_menu}
        end
    end

    def self.search_by_title
        CommandLineInterface.logo("./design/logo_small.png", false)

        @@title_search = @@prompt.ask("Please enter the title you are looking for:"){ 
            |input| input.validate /^^(?=.{1,40}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._ ]+(?<![_.])$/, "Sorry, your title entry must be at least 1 character and not contain special symbols." }
        if Poem.find_by("title like ?", "%#{@@title_search}%")
            p = Poem.where("title like ?", "%#{@@title_search}%").map do |poem|
                poem.title
            end
            @@selected_title = @@prompt.select("Select Poem:", p) 
            poem_title({title: @@selected_title}) 
        else
            puts "Sorry, poem was not found. Please try another input."
            @@menu_selection_footer = @@prompt.select("Options:") do |menu|
                menu.choice '* Try Again', -> {search_by_title}
                menu.choice '* Back to Poem Search', -> {Poem.search_for_poem}
            end
        end
    end

    def self.menu_selection_footer
        @@menu_selection_footer
    end

    def self.poem_title(arg)
        CommandLineInterface.logo("./design/logo_small.png", false)
        i = Poem.find_by(arg)
        puts " "
        puts i.title.colorize(:color => :black, :background => :white)
        puts "By #{i.author.name}".colorize(:color => :black, :background => :white)
        puts i.content
        puts " "
        @@menu_selection_footer = @@prompt.select("Options:") do |menu|
            menu.choice '* Play Music', -> {Poem.music_selection}
            menu.choice '* Stop Music', -> {Poem.stop_song}
            if Lesson.exists?(user_id: User.user_id, poem_id: i.id)
                menu.choice '* Remove from your collection', -> {
                    Lesson.find_by(user_id: User.user_id, poem_id: i.id).destroy
                    CommandLineInterface.logo("./design/logo_small.png", false);
                    CommandLineInterface.general_menu}
            else
                menu.choice '* Add to collection', -> {
                    Lesson.lesson_creation(user_id: User.user_id, poem_id: i.id);
                    CommandLineInterface.logo("./design/logo_small.png", false);
                    CommandLineInterface.general_menu}
            end
            menu.choice '* Back to Title Search', -> {Poem.search_by_title}
        end  
    end

    def self.music_selection
        @@song_choice = @@prompt.select("Please select one of the options below:") do |menu|
            menu.choice '* Song of the Gods', -> {song("./music/Halo.mp3")}
            menu.choice '* Brandenburg Concerto', -> {song("./music/BrandenburgConcerto.mp3")}
            menu.choice '* Consolation 3', -> {song("./music/Consolation3.mp3")}
            menu.choice '* Four Seasons Spring', -> {song("./music/FourSeasonsSpring.mp3")}
            menu.choice '* Fur Elise', -> {song("./music/FurElise.mp3")}
            menu.choice '* Moonlight Sonata', -> {song("./music/MoonlightSonata.mp3")}
            menu.choice '* Requiem Lacrimosa', -> {song("./music/RequiemLacrimosa.mp3")}
            menu.choice "* Salut D'Amour", -> {song("./music/SalutD'Amour.mp3")}
            menu.choice '* Scherezade Op. 35. III', -> {song("./music/ScherezadeOp35.mp3")}
            menu.choice '* Suite Bergamasque', -> {song("./music/SuiteBergamasque.mp3")}
            menu.choice '* Swan Lake Finale', -> {song("./music/SwanLake.mp3")}
            menu.choice '* Tragic Overture', -> {song("./music/TragicOverture.mp3")}
        end
        poem_title({title: @@selected_title})
    end

    def self.song(file_path)
        pid = fork{ exec 'killall', "afplay" }
        sleep(0.5)
        pid = fork{ exec 'afplay', file_path }
    end

    def self.stop_song
        pid = fork{ exec 'killall', "afplay" }
        CommandLineInterface.logo("./design/logo_small.png", false);
        poem_title({title: @@selected_title})
    end

end