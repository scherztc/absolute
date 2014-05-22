Blacklight.onLoad(function() {
  // This takes care of loading the angular app with Turbolinks
  var app = angular.module('myApp', []);
  app.controller('TeiViewer', ['$scope', TeiViewer])
  app.directive('teiViewer', TeiViewerDirective)
  angular.bootstrap('body', ['myApp']);
})

function TeiViewer($scope) {
  $scope.currentPage = 1;
  $scope.formNumber = 1;
  $scope.maxPage = "1"

  $scope.previousPage = function (){
    if($scope.currentPage > 1) {
      $scope.currentPage--;
      $scope.formNumber = $scope.currentPage;
    }
  }

  $scope.nextPage = function (){
    if($scope.currentPage < $scope.maxPage) {
      $scope.currentPage++;
      $scope.formNumber = $scope.currentPage;
    }
  }

  $scope.textUpdated = function () {
    if ($scope.formNumber < 1) {
        // Less than one
      $scope.formNumber = $scope.currentPage;
    } else {
      var newVal = parseInt($scope.formNumber);
      if (newVal <= $scope.maxPage) {
        // Looks good, update currentPage
        $scope.currentPage = newVal;
      } else {
        // Larger than the allowed value
        $scope.formNumber = $scope.currentPage;
      }
    }
  }
}


function TeiViewerDirective() {
    function link(scope, element, attrs) {
        scope.maxPage = parseInt(document.getElementById('tei-content').getAttribute('data-max-pages'));

        function scrollToPage() {
            var el = document.getElementById('page-' + scope.currentPage);
            var container = document.getElementById('tei-container');
            container.scrollTop = el.offsetTop;
        };

        scope.$watch("currentPage", function(value) {
            scrollToPage();
        });
    }
    return {
        restrict: 'E',
        transclude: true,
        templateUrl: 'tei_viewer.html',
        link: link
    };
}
