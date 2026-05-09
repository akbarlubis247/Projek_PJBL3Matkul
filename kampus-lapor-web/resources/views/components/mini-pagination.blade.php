@props(['paginator'])

@if ($paginator->hasPages())
    <nav class="mini-pagination" aria-label="Pagination">
        @if ($paginator->onFirstPage())
            <span class="mini-page disabled">&lt;</span>
        @else
            <a class="mini-page" href="{{ $paginator->previousPageUrl() }}" rel="prev">&lt;</a>
        @endif

        <span class="mini-page-info">
            {{ $paginator->firstItem() }}-{{ $paginator->lastItem() }} dari {{ $paginator->total() }}
        </span>

        @if ($paginator->hasMorePages())
            <a class="mini-page" href="{{ $paginator->nextPageUrl() }}" rel="next">&gt;</a>
        @else
            <span class="mini-page disabled">&gt;</span>
        @endif
    </nav>
@endif
