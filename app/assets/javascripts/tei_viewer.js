function TeiViewer($scope) {
  $scope.currentPage = 1;

  $scope.formNumber = 1;

  $scope.previousPage = function (){
    if($scope.currentPage > 1) {
      $scope.currentPage--;
      $scope.formNumber = $scope.currentPage;
      $scope.scrollToPage();
    }
  }

  var max = parseInt(document.getElementById('tei-content').getAttribute('data-max-pages'));

  $scope.nextPage = function (){
    if($scope.currentPage < max) {
      $scope.currentPage++;
      $scope.formNumber = $scope.currentPage;
      $scope.scrollToPage();
    }
  }

  $scope.textUpdated = function () {
    if ($scope.formNumber < 1) {
        // Less than one
      $scope.formNumber = $scope.currentPage;
    } else {
      var newVal = parseInt($scope.formNumber);
      if (newVal <= max) {
        // Looks good, update currentPage
        $scope.currentPage = newVal;
        $scope.scrollToPage();
      } else {
        // Larger than the allowed value
        $scope.formNumber = $scope.currentPage;
      }
    }
  }

  $scope.scrollToPage = function (){
    var el = document.getElementById('page-' + $scope.currentPage);
    var container = document.getElementById('tei-container');
    container.scrollTop = el.offsetTop;
  };
}
