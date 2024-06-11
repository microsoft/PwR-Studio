import React, { useEffect, useRef } from 'react';
import mermaid, { DetailedError } from 'mermaid';
import '@/styles/components/Mermaid.scss';

interface props {
    chart: string;
}
const MermaidChart = (props:props) => {
  const mermaidRef = useRef(null);
  const [error, setError] = React.useState<any>(null);

  useEffect(() => {
    mermaid.initialize({
      startOnLoad: false,
      theme: 'default'
    });
    if (mermaidRef.current) {
      mermaid.parseError = (err: string | DetailedError | unknown, hash?: any) => {
        setError(err);
      }
      mermaid.contentLoaded();
      mermaid.init(undefined, mermaidRef.current);
    }
  }, [props.chart]);
  if (error) {
    return <div className="mermaid-error">{error?.name || error}</div>;
  }
  if (!props.chart) {
    return <></>;
  }
  return <div ref={mermaidRef} className="mermaid">{props.chart}</div>;
};

export default MermaidChart;
