@extends('layouts.app')

@section('content')
<form action="{{ route('statuses.store') }}" method="POST">
    @csrf
    <textarea name="body" cols="30" rows="10"></textarea>
    <button type="submit" id="create-status">Create status</button>
</form>
@endsection