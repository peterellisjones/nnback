'use strict'

app = angular.module('nnbackApp')
app.controller 'MainCtrl', ($scope, $document) ->


    $scope.visual_items = [1,3,5,7]
    $scope.audio_items = [0,1,2,3]

    $scope.cell_status = (i) =>
      if i == $scope.visual_item
        "active"
      else 
        "inactive"

    $scope.difficulty = 2
    $scope.difficulty_options = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]

    $scope.stop = () ->
      $scope.tries = 0
      $scope.success = 0
      $scope.accuracy = 0
      $scope.longest_chain = 0
      $scope.current_chain = 0
      $scope.false_positives = 0
      $scope.false_negatives = 0
      $scope.visual_item = null
      $scope.visual_queue = []
      $scope.audio_item = null
      $scope.audio_queue = []

      $scope.status = "paused"
      $scope.shortcuts = [{key: 'enter', description: 'begin'}] 
      $scope.visual_item = null

      $scope.$apply()

    $scope.start = () ->
      console.log "starting"
      $scope.status = "running"
      $scope.shortcuts = [
        {key: 'enter', description: 'stop'},
        {key: 'up', description: 'no match'},
        {key: 'left', description: 'visual match'},
        {key: 'right', description: 'sound match'},
        {key: 'down', description: 'visual+sound match'},]
      $scope.next()

    $scope.next = () ->
      console.log "next"
      if $scope.visual_item != null
        $scope.visual_queue.unshift $scope.visual_item
      $scope.visual_item = $scope.visual_items[Math.floor(Math.random() * $scope.visual_items.length)]
      if $scope.audio_item != null
        $scope.audio_queue.unshift $scope.audio_item
      $scope.audio_item = $scope.audio_items[Math.floor(Math.random() * $scope.audio_items.length)]
      document.getElementById("audio-#{$scope.audio_item}").play()
      $scope.$apply()

    $scope.evaluate = (visual, audio) ->
      console.log "GUESS: #{visual}, #{audio}"
      $scope.tries += 1

      success = false

      # if the queue is not long enough
      if $scope.visual_queue.length < $scope.difficulty
        if !visual
          success = true
        else
          $scope.false_positives += 1
      # otherwise if queue is long enough
      else
        visual_answer = $scope.visual_queue.pop() == $scope.visual_item
        audio_answer = $scope.audio_queue.pop() == $scope.audio_item

        if visual == visual_answer && audio == audio_answer
          success = true

        # update stats
        if visual_answer && !visual
          $scope.false_negatives += 1
        if audio_answer && !audio
          $scope.false_negatives += 1
        if !visual_answer && visual
          $scope.false_positives += 1
        if !audio_answer && audio
          $scope.false_positives += 1

      if success
        $scope.success += 1
        $scope.current_chain += 1
        if $scope.current_chain > $scope.longest_chain
          $scope.longest_chain = $scope.current_chain
      else
        $scope.current_chain = 0

      $scope.accuracy = Math.round(100.0*$scope.success/$scope.tries)
      $scope.next()

    Mousetrap.bind 'up', (e) ->
      if $scope.status == 'running'
        $scope.evaluate(false, false)

    Mousetrap.bind 'left', (e) ->
      if $scope.status == 'running'
        $scope.evaluate(true, false)

    Mousetrap.bind 'right', (e) ->
      if $scope.status == 'running'
        $scope.evaluate(false, true)

    Mousetrap.bind 'down', (e) ->
      if $scope.status == 'running'
        $scope.evaluate(true, true)

    Mousetrap.bind 'enter', (e) ->
      if $scope.status == "paused"
        $scope.start()
      else
        $scope.stop()
