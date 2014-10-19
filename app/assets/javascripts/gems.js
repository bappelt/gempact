(function() {

  var gem = $('.gem-details').data('gem');

  $('.gem-details .gem-dependencies').DataTable();

  $('.gem-details .gem-dependents').DataTable({
    serverSide: true,
    ajax: '/datatables/gems/:gem/dependents'.replace(':gem', gem),
    columns: [
      {
        data: 'name',
        render: function(name) {
          var template = '<a href="/gems/:name">:name</a>';
          return template.replace(/:name/g, name);
        }
      }
    ]
  });

  $('.gem-details .gem-dependents-transitive').DataTable();
}());
