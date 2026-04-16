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

    // Get selected years
    document.querySelectorAll('.js_filter_years_list .js_filter_option').forEach(function(label) {
      var input = label.querySelector('input');
      if (input && input.checked) {
        var value = label.getAttribute('data-option');
        if (value) filters.years.push(value);
      }
    });

    // Get selected tags
    document.querySelectorAll('.js_filter_tags_list .js_filter_option').forEach(function(label) {
      var input = label.querySelector('input');
      if (input && input.checked) {
        var value = label.getAttribute('data-option');
        if (value) filters.tags.push(value);
      }
    });

    var titleInput = document.querySelector('.js_filter_title_input');
    if (titleInput) {
      filters.q = (titleInput.value || '').trim();
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
    if (!titleInput) return;

    var debounceId = null;
    titleInput.addEventListener('input', function() {
      clearTimeout(debounceId);
      debounceId = setTimeout(function() {
        var query = (titleInput.value || '').trim();
        if (query.length === 0 || query.length >= 2) {
          applyFilters();
        }
      }, 420);
    });
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
      var selector = '.js_filter_years_list .js_filter_option[data-option="' + year + '"] input';
      var input = document.querySelector(selector);
      if (input) {
        input.checked = true;
        // Trigger change event to update UI
        triggerChange(input);
      }
    });
    
    // Check tags from URL
    params.getAll('tag').forEach(function(tag) {
      var selector = '.js_filter_tags_list .js_filter_option[data-option="' + tag + '"] input';
      var input = document.querySelector(selector);
      if (input) {
        input.checked = true;
        triggerChange(input);
      }
    });

    var q = params.get('q');
    if (q) {
      var titleInput = document.querySelector('.js_filter_title_input');
      if (titleInput) {
        titleInput.value = q;
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

})();

