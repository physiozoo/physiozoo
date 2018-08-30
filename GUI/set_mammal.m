%%
    function [mammal, mammal_index] = set_mammal(DATA, mammal)
        %         DATA.mammal = mammal;
        if strcmpi(mammal, 'rabbit')
            %             DATA.mammal = 'rabbit';
            mammal = 'rabbit';
        elseif ~isempty(regexpi(mammal, 'mice|mouse'))
            %             DATA.mammal = 'mouse';
            mammal = 'mouse';
        elseif ~isempty(regexpi(mammal, 'dog|dogs|canine'))
            %             DATA.mammal = 'dog';
            mammal = 'dog';
        end
        %         DATA.mammal_index = find(strcmp(DATA.mammals, DATA.mammal));
        mammal_index = find(strcmp(DATA.mammals, mammal));
        %         if mammal_index == 0 % DATA.mammal_index == 0
        % %             DATA.mammal_index = 1;
        %             mammal_index = 1;
        % %             DATA.mammal = 'human';
        %             mammal = 'human';
        %         end
    end