%%
    function setSliderProperties(slider_handle, maxSignalLength, MyWindowSize, SliderStep)
        set(slider_handle, 'Min', 0);
        set(slider_handle, 'Max', maxSignalLength - MyWindowSize);
        set(slider_handle, 'Value', 0);
        set(slider_handle, 'SliderStep', [SliderStep/10 SliderStep]);
    end