/**
 * Custom filter functionality for the blog
 * Handles dropdown close on outside click and actual filtering via URL params
 */
(function() {
  'use strict';

  // Wait for DOM to be ready
  document.addEventListener('DOMContentLoaded', function() {
    initFilterDropdowns();
    initFilterSubmit();
    initTitleLiveFilter();
    initFiltersFromUrl();
    restoreTitleFocus();
  });

  /**
   * Close dropdowns when clicking outside
   */
  function initFilterDropdowns() {
    document.addEventListener('click', function(event) {
      var filterContainers = document.querySelectorAll('.section-content__filter');
      
      filterContainers.forEach(function(container) {
        var list = container.querySelector('.section-content__filter-list-wrapper');
        var btn = container.querySelector('.section-content__filter-ico');
        
        if (!list || !btn) return;
        
        // If click is outside this filter container, close the dropdown
        if (!container.contains(event.target)) {
          list.classList.remove('_active');
          btn.classList.remove('_active');
        }
      });
    });

    // Also close when pressing Escape
    document.addEventListener('keydown', function(event) {
      if (event.key === 'Escape') {
        closeAllDropdowns();
      }
    });
  }

  function closeAllDropdowns() {
    document.querySelectorAll('.section-content__filter-list-wrapper._active').forEach(function(list) {
      list.classList.remove('_active');
    });
    document.querySelectorAll('.section-content__filter-ico._active').forEach(function(btn) {
      btn.classList.remove('_active');
    });
  }

  /**
   * Handle filter submission
   */
  function initFilterSubmit() {
    // Submit buttons in dropdowns
    document.querySelectorAll('.section-content__filter-btn-submit button').forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        applyFilters();
      });
    });

    // "Remove all filters" button
    document.querySelectorAll('.section-content__filter-rem-choose button').forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        clearAllFilters();
      });
    });

    // Delete button in individual filter dropdown
    document.querySelectorAll('.section-content__filter-btn-delete button').forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        // Let the original handler clear checkboxes, then apply filters
        setTimeout(function() {
          applyFilters();
        }, 100);
      });
    });

    // Mobile drawer action buttons.
    document.querySelectorAll('.section__filet-submit-btn--mobile button').forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        applyFilters();
      });
    });

    document.querySelectorAll('.section__filet-cansel-btn--mobile button').forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        closeMobileFiltersDrawer();
      });
    });

    // Mobile title search icon triggers filtering immediately.
    document.querySelectorAll('.js_filter_title_submit_mobile').forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        applyFilters();
      });
    });
  }

  /**
   * Get currently selected filters
   */
  function getSelectedFilters() {
    var filters = {
      years: [],
      tags: [],
      q: ''
    };

    filters.years = collectCheckedOptions([
      '.js_filter_years_list .js_filter_option',
      '.js_filter_years_list_mobile .js_filter_option'
    ]);

    filters.tags = collectCheckedOptions([
      '.js_filter_tags_list .js_filter_option',
      '.js_filter_tags_list_mobile .js_filter_option'
    ]);

    var mobileTitleInput = document.querySelector('.js_filter_title_input_mobile');
    var desktopTitleInput = document.querySelector('.js_filter_title_input');
    var mobileValue = mobileTitleInput ? (mobileTitleInput.value || '').trim() : '';
    var desktopValue = desktopTitleInput ? (desktopTitleInput.value || '').trim() : '';
    var activeElement = document.activeElement;

    if (activeElement === desktopTitleInput) {
      filters.q = desktopValue;
    } else if (activeElement === mobileTitleInput) {
      filters.q = mobileValue;
    } else {
      // Prefer desktop value for desktop flow, fallback to mobile value.
      filters.q = desktopValue || mobileValue;
    }

    return filters;
  }

  /**
   * Apply filters by reloading page with URL params
   */
  function applyFilters() {
    var filters = getSelectedFilters();
    var params = new URLSearchParams();
    
    // Add selected years
    filters.years.forEach(function(year) {
      params.append('year', year);
    });
    
    // Add selected tags
    filters.tags.forEach(function(tag) {
      params.append('tag', tag);
    });

    // Add title query only when it is meaningful
    if (filters.q.length >= 2) {
      params.set('q', filters.q);
    }
    
    // Reset to page 1 when filtering
    if (filters.years.length > 0 || filters.tags.length > 0 || filters.q.length >= 2) {
      params.set('page', '1');
    }
    
    // Reload with new params
    var queryString = params.toString();
    var newUrl = window.location.pathname + (queryString ? '?' + queryString : '');
    
    console.log('Applying filters:', filters);
    console.log('New URL:', newUrl);

    persistTitleFocusState();
    window.location.href = newUrl;
  }

  function initTitleLiveFilter() {
    var titleInput = document.querySelector('.js_filter_title_input');
    var mobileTitleInput = document.querySelector('.js_filter_title_input_mobile');
    if (!titleInput && !mobileTitleInput) return;

    var debounceId = null;
    if (titleInput) {
      titleInput.addEventListener('input', function() {
        // Keep both fields in sync to avoid stale value overrides.
        if (mobileTitleInput && mobileTitleInput.value !== titleInput.value) {
          mobileTitleInput.value = titleInput.value;
        }
        clearTimeout(debounceId);
        debounceId = setTimeout(function() {
          var query = (titleInput.value || '').trim();
          if (query.length === 0 || query.length >= 2) {
            applyFilters();
          }
        }, 420);
      });
    }

    // Mobile title field uses explicit "Apply" action.
    if (mobileTitleInput && titleInput) {
      mobileTitleInput.addEventListener('input', function() {
        if (titleInput.value !== mobileTitleInput.value) {
          titleInput.value = mobileTitleInput.value;
        }
      });
      mobileTitleInput.addEventListener('keydown', function(event) {
        if (event.key !== 'Enter') return;
        event.preventDefault();
        applyFilters();
      });
    }
  }

  /**
   * Clear all filters and reload
   */
  function clearAllFilters() {
    console.log('Clearing all filters');
    window.location.href = window.location.pathname;
  }

  /**
   * Initialize checkboxes from URL params on page load
   */
  function initFiltersFromUrl() {
    var params = new URLSearchParams(window.location.search);
    
    // Check years from URL
    params.getAll('year').forEach(function(year) {
      document.querySelectorAll('.js_filter_years_list .js_filter_option[data-option="' + year + '"] input, .js_filter_years_list_mobile .js_filter_option[data-option="' + year + '"] input').forEach(function(input) {
        input.checked = true;
        triggerChange(input);
      });
    });
    
    // Check tags from URL
    params.getAll('tag').forEach(function(tag) {
      document.querySelectorAll('.js_filter_tags_list .js_filter_option[data-option="' + tag + '"] input, .js_filter_tags_list_mobile .js_filter_option[data-option="' + tag + '"] input').forEach(function(input) {
        input.checked = true;
        triggerChange(input);
      });
    });

    var q = params.get('q');
    if (q) {
      var titleInput = document.querySelector('.js_filter_title_input');
      if (titleInput) {
        titleInput.value = q;
      }
      var mobileTitleInput = document.querySelector('.js_filter_title_input_mobile');
      if (mobileTitleInput) {
        mobileTitleInput.value = q;
      }
    }
  }

  function persistTitleFocusState() {
    var titleInput = document.querySelector('.js_filter_title_input');
    if (!titleInput) return;
    if (document.activeElement !== titleInput) return;

    try {
      sessionStorage.setItem('lm_filter_title_focus', '1');
      sessionStorage.setItem('lm_filter_title_cursor', String(titleInput.value.length));
    } catch (_e) {}
  }

  function restoreTitleFocus() {
    var titleInput = document.querySelector('.js_filter_title_input');
    if (!titleInput) return;

    try {
      var shouldFocus = sessionStorage.getItem('lm_filter_title_focus') === '1';
      if (!shouldFocus) return;

      sessionStorage.removeItem('lm_filter_title_focus');
      window.requestAnimationFrame(function() {
        titleInput.focus({ preventScroll: true });
        var cursor = Number(sessionStorage.getItem('lm_filter_title_cursor') || titleInput.value.length);
        titleInput.setSelectionRange(cursor, cursor);
        sessionStorage.removeItem('lm_filter_title_cursor');
      });
    } catch (_e) {}
  }

  function triggerChange(element) {
    var event = new Event('change', { bubbles: true });
    element.dispatchEvent(event);
  }

  function collectCheckedOptions(selectors) {
    var values = new Set();
    selectors.forEach(function(selector) {
      document.querySelectorAll(selector).forEach(function(label) {
        var input = label.querySelector('input');
        if (!input || !input.checked) return;
        var value = label.getAttribute('data-option');
        if (value) values.add(value);
      });
    });
    return Array.from(values);
  }

  function closeMobileFiltersDrawer() {
    var drawer = document.querySelector('.section__filter-wrapper--mobile');
    if (!drawer) return;
    drawer.classList.remove('_active');
    document.body.classList.remove('disable-scroll');
  }

})();

