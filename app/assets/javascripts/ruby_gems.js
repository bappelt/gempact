(function() {
  var gem = $('.gem-details').data('gem');

  var setupDataTables = function() {
    var nameRenderer = function(name) {
      var template = '<a href="/gems/:name">:name</a>';
      return template.replace(/:name/g, name);
    };

    var processingContent = 'Loading <img alt="Loading bars" src="/assets/loading-spin.svg">';

    $('.gem-details #gem-dependencies > table').DataTable();

    $('.gem-details #gem-dependents > table').DataTable({
      serverSide: true,
      ajax: '/datatables/gems/:gem/dependents'.replace(':gem', gem),
      columns: [{
        data: 'name',
        render: nameRenderer
      }]
    });

    $('.gem-details #gem-dependents-transitive > table').DataTable({
      serverSide: true,
      ajax: '/datatables/gems/:gem/transitive_dependents'.replace(':gem', gem),
      processing: true,
      language: {
        processing: processingContent
      },
      columns: [{
        data: 'name',
        render: nameRenderer
      }]
    });
  };

  $(function() {
    var countDependentsUrl = '/gems/:gem/dependents/count'.replace(':gem', gem),
        countTransitiveDependentsUrl = '/gems/:gem/transitive_dependents/count'.replace(':gem', gem);

    $.get(countDependentsUrl).done(function(response) {
      $('#gem-dependents-count').text(response);
    });

    $.get(countTransitiveDependentsUrl).done(function(response) {
      $('#gem-transitive-dependents-count').text(response);
    });

    setupDataTables();
  });
}());
