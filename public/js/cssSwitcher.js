document.addEventListener('DOMContentLoaded', function() {
    const cssToggle = document.getElementById('alternativeCSS');
    if (!cssToggle) {
        console.error('CSS toggle checkbox not found');
        return;
    }

    const defaultCSS = '/css/empty.css';
    const alternativeCSS = '/css/clean-ui.css';

    // Load saved preference
    cssToggle.checked = options.buttons.alternativeCSS === 'true';

    function updateCSS(useAlternative) {
        let cssLink = document.querySelector('link[href^="/css/"]');
        if (!cssLink) {
            console.error('CSS link not found');
            return;
        }
        if (useAlternative) {
            cssLink.href = alternativeCSS;
        } else {
            cssLink.href = defaultCSS;
        }
    }

    // Apply saved preference
    updateCSS(cssToggle.checked);

    cssToggle.addEventListener('change', function() {
        updateCSS(this.checked);
	    options.buttons.alternativeCSS = (this.checked.toString());
	    options.save();
    });
});